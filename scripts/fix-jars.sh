#!/bin/sh
# Third-party jar fixes for the base image apache/hive:standalone-metastore-4.1.0 (Hadoop 3.4.1 dist).
# Jars on the metastore classpath are replaced in place by patched releases from Maven Central; jars that are
# not on it (YARN/test/client bundles, embedded Derby) are removed. The classpath is printed at metastore
# startup (STARTUP_MSG: classpath).
set -eu

CENTRAL=https://repo1.maven.org/maven2
HADOOP=/opt/hadoop/share/hadoop

# swap <group path> <artifact> <old version> <new version>: replace <artifact>-<old>*.jar in every lib dir (same dir, same classifier)
swap() {
  for old in /opt/hive/lib/$2-$3*.jar $HADOOP/*/lib/$2-$3*.jar; do
    [ -e "$old" ] || continue
    new=$(basename "$old" | sed "s/^$2-$3/$2-$4/")
    curl -fsSL --retry 3 -o "$(dirname "$old")/$new" "$CENTRAL/$1/$2/$4/$new"
    rm "$old"
  done
}

for jar in $HADOOP/common/lib/netty-*-4.1.100.Final*.jar; do
  artifact=$(basename "$jar")
  swap io/netty "${artifact%%-4.1.100.Final*}" 4.1.100.Final 4.1.137.Final
done
for artifact in bcprov-jdk18on bcpkix-jdk18on bcutil-jdk18on; do
  swap org/bouncycastle "$artifact" 1.78.1 1.85
done
swap org/apache/avro avro 1.9.2 1.12.0

rm -f $HADOOP/client/hadoop-client-minicluster-*.jar $HADOOP/client/hadoop-client-runtime-*.jar \
      $HADOOP/tools/lib/bundle-*.jar \
      $HADOOP/yarn/timelineservice/lib/htrace-core-*.jar \
      $HADOOP/yarn/hadoop-yarn-applications-catalog-webapp-*.war \
      /opt/hive/lib/derby-*.jar

# fail the build if a pattern above silently matched nothing
left=$(ls $HADOOP/*/lib/netty-*-4.1.100.Final*.jar $HADOOP/*/lib/bc*-1.78.1.jar $HADOOP/*/lib/avro-1.9.2.jar 2>/dev/null || true)
[ -z "$left" ] || { echo "not replaced: $left" >&2; exit 1; }
