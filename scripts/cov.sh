clear
swift test --enable-code-coverage
llvm-cov show \
    .build/debug/BlockSetPackageTests.xctest \
    -instr-profile=.build/debug/codecov/default.profdata \
    -format=html \
    -output-dir=.coverage
