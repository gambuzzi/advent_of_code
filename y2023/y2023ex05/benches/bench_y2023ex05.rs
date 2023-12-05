use y2023ex05::{part1, part2};

use criterion::{black_box, criterion_group, criterion_main, Criterion};

fn criterion_benchmark(c: &mut Criterion) {
    let input: &str = include_str!("../input.txt");
    let lines: Vec<String> = input.lines().map(|line| line.to_string()).collect();
    c.bench_function("y2023ex05::part1", |b| b.iter(|| part1(black_box(&lines))));
    c.bench_function("y2023ex05::part2", |b| b.iter(|| part2(black_box(&lines))));
}

criterion_group!(benches, criterion_benchmark);
criterion_main!(benches);
