load(
    "@com_googlesource_gerrit_bazlets//tools:junit.bzl",
    "junit_tests",
)

def tests(tests):
    for src in tests:
        name = src[len("tst/"):len(src) - len(".java")].replace("/", "_")
        labels = []
        if name.startswith("org_eclipse_jgit_"):
            package = name[len("org.eclipse.jgit_"):]
            if package.startswith("internal_storage_"):
                package = package[len("internal.storage_"):]
            index = package.find("_")
            if index > 0:
                labels.append(package[:index])
            else:
                labels.append(index)
        if "lib" not in labels:
            labels.append("lib")

        # TODO(http://eclip.se/534285): Make this test pass reliably
        # and remove the flaky attribute.
        flaky = src.endswith("CrissCrossMergeTest.java")

        additional_deps = []
        if src.endswith("RootLocaleTest.java"):
            additional_deps = [
                "//org.eclipse.jgit.pgm:pgm",
                "//org.eclipse.jgit.ui:ui",
            ]
        if src.endswith("WalkEncryptionTest.java"):
            additional_deps = [
                "//org.eclipse.jgit:insecure_cipher_factory",
            ]
        if src.endswith("OpenSshConfigTest.java"):
            additional_deps = [
                "//lib:jsch",
            ]
        if src.endswith("JschConfigSessionFactoryTest.java"):
            additional_deps = [
                "//lib:jsch",
            ]
        if src.endswith("ArchiveCommandTest.java"):
            additional_deps = [
                "//lib:commons-compress",
                "//lib:xz",
                "//org.eclipse.jgit.archive:jgit-archive",
            ]

        heap_size = "-Xmx256m"
        if src.endswith("HugeCommitMessageTest.java"):
            heap_size = "-Xmx512m"

        junit_tests(
            name = name,
            tags = labels,
            srcs = [src],
            deps = additional_deps + [
                ":helpers",
                ":tst_rsrc",
                "//lib:javaewah",
                "//lib:junit",
                "//lib:slf4j-api",
                "//org.eclipse.jgit:jgit",
                "//org.eclipse.jgit.junit:junit",
                "//org.eclipse.jgit.lfs:jgit-lfs",
            ],
            flaky = flaky,
            jvm_flags = [heap_size, "-Dfile.encoding=UTF-8"],
        )
