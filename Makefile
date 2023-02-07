.POSIX:

ROOTDIR  = $$PWD

all:
	@if [ ! -d build ]; then \
		mkdir build;     \
	fi
	@cd build; voc -s ${ROOTDIR}/../src/unixFiles.Mod

test:
	@if [ ! -d build ]; then      \
		echo Run make, first; \
		exit 1;               \
	fi
	@cd build; voc ${ROOTDIR}/../tests/testUnixFiles.Mod -m \
		       > /dev/null 2>&1                               \
		       || (echo Failed to compile, have you run make? \
			&& exit 1)

clean:
	rm -rf build

.PHONY: test
