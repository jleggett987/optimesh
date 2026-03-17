pub fn compute_sample(input: u32) -> u32 {
    input * 2
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn compute_sample_doubles_input() {
        assert_eq!(compute_sample(4), 8);
    }
}
