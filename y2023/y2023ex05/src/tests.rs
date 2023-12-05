use y2023ex05::solve;

#[cfg(test)]
mod tests {
    use super::*;
    const INPUT: &str = include_str!("../input.txt");

    #[test]
    fn test_part1() {
        let lines: Vec<String> = INPUT.lines().map(|line| line.to_string()).collect();
        assert_eq!(part1(&lines), 806029445);
    }

    #[test]
    fn test_part2() {
        let lines: Vec<String> = INPUT.lines().map(|line| line.to_string()).collect();
        assert_eq!(part1(&lines), 59370572);
    }
}
