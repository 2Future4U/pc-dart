// See file LICENSE for more information.

library pointycastle.benchmark.digests.sha512t_benchmark;

import "../benchmark/digest_benchmark.dart";

main() {
  new DigestBenchmark("SHA-512/504").report();
}
