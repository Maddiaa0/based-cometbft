use dep::std;

// A simple and naive VRF
// Naive as we do not validate who the proposal has come from with the sig - just lazy
fn main(proposer: pub Field, salt: Field) -> pub Field {
    // blah blah not preimage resistant let me live
    std::hash::pedersen_hash([proposer, salt])
}


#[test]
fn mama_said_to_test_stuff() {
    let proposer = 69;
    let salt = 420;
    let result = main(proposer, salt);
    assert_eq(0x0f89a19592f02b1af4aee36a13b30c8aae01cb1b905300f7d038a3169137a6e7, result);
}