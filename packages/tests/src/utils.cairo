use shinigami_compiler::compiler::CompilerImpl;
use shinigami_engine::engine::{Engine, EngineImpl, EngineInternalTrait};
use shinigami_engine::hash_cache::HashCacheImpl;
use shinigami_engine::transaction::{
    EngineTransaction, EngineTransactionInput, EngineTransactionOutput, EngineOutPoint,
};

// Runs a basic bitcoin script as the script_pubkey with empty script_sig
pub fn test_compile_and_run(program: ByteArray) -> Engine<EngineTransaction> {
    let mut compiler = CompilerImpl::new();
    let bytecode = compiler.compile(program).unwrap();
    // TODO: Nullable
    let hash_cache = HashCacheImpl::new(Default::default());
    let mut engine = EngineImpl::new(@bytecode, Default::default(), 0, 0, 0, @hash_cache).unwrap();
    let res = engine.execute();
    assert!(res.is_ok(), "Execution of the program failed");
    engine
}

// Runs a bitcoin script `program` as script_pubkey with corresponding `transaction`
pub fn test_compile_and_run_with_tx(
    program: ByteArray, transaction: EngineTransaction,
) -> Engine<EngineTransaction> {
    let mut compiler = CompilerImpl::new();
    let mut bytecode = compiler.compile(program).unwrap();
    let hash_cache = HashCacheImpl::new(@transaction);
    let mut engine = EngineImpl::new(@bytecode, @transaction, 0, 0, 0, @hash_cache).unwrap();
    let res = engine.execute();
    assert!(res.is_ok(), "Execution of the program failed");
    engine
}

// Runs a bitcoin script `program` as script_pubkey with corresponding `transaction` and 'flags'
pub fn test_compile_and_run_with_tx_flags(
    program: ByteArray, transaction: EngineTransaction, flags: u32,
) -> Engine<EngineTransaction> {
    let mut compiler = CompilerImpl::new();
    let mut bytecode = compiler.compile(program).unwrap();
    let hash_cache = HashCacheImpl::new(@transaction);
    let mut engine = EngineImpl::new(@bytecode, @transaction, 0, flags, 0, @hash_cache).unwrap();
    let res = engine.execute();
    assert!(res.is_ok(), "Execution of the program failed");
    engine
}

// Runs a bitcoin script `program` as script_pubkey with empty script_sig expecting an error
pub fn test_compile_and_run_err(
    program: ByteArray, expected_err: felt252,
) -> Engine<EngineTransaction> {
    let mut compiler = CompilerImpl::new();
    let bytecode = compiler.compile(program).unwrap();
    let hash_cache = HashCacheImpl::new(Default::default());
    let mut engine = EngineImpl::new(@bytecode, Default::default(), 0, 0, 0, @hash_cache).unwrap();
    let res = engine.execute();
    assert!(res.is_err(), "Execution of the program did not fail as expected");
    let err = res.unwrap_err();
    assert!(err == expected_err, "Program did not return the expected error");
    engine
}

// Runs a bitcoin script `program` as script_pubkey with corresponding `transaction` expecting an
// error
pub fn test_compile_and_run_with_tx_err(
    program: ByteArray, transaction: EngineTransaction, expected_err: felt252,
) -> Engine<EngineTransaction> {
    let mut compiler = CompilerImpl::new();
    let mut bytecode = compiler.compile(program).unwrap();
    let hash_cache = HashCacheImpl::new(@transaction);
    let mut engine = EngineImpl::new(@bytecode, @transaction, 0, 0, 0, @hash_cache).unwrap();
    let res = engine.execute();
    assert!(res.is_err(), "Execution of the program did not fail as expected");
    let err = res.unwrap_err();
    assert!(err == expected_err, "Program did not return the expected error");
    engine
}

// Runs a bitcoin script `program` as script_pubkey with corresponding `transaction` and 'flags'
// expecting an error
pub fn test_compile_and_run_with_tx_flags_err(
    program: ByteArray, transaction: EngineTransaction, flags: u32, expected_err: felt252,
) -> Engine<EngineTransaction> {
    let mut compiler = CompilerImpl::new();
    let mut bytecode = compiler.compile(program).unwrap();
    let hash_cache = HashCacheImpl::new(@transaction);
    let mut engine = EngineImpl::new(@bytecode, @transaction, 0, flags, 0, @hash_cache).unwrap();
    let res = engine.execute();
    assert!(res.is_err(), "Execution of the program did not fail as expected");
    let err = res.unwrap_err();
    assert!(err == expected_err, "Program did not return the expected error");
    engine
}

pub fn check_dstack_size(ref engine: Engine<EngineTransaction>, expected_size: usize) {
    let dstack = engine.get_dstack();
    assert!(dstack.len() == expected_size, "Dstack size is not as expected");
}

pub fn check_astack_size(ref engine: Engine<EngineTransaction>, expected_size: usize) {
    let astack = engine.get_astack();
    assert!(astack.len() == expected_size, "Astack size is not as expected");
}

pub fn check_expected_dstack(ref engine: Engine<EngineTransaction>, expected: Span<ByteArray>) {
    let dstack = engine.get_dstack();
    assert!(dstack == expected, "Dstack is not as expected");
}

pub fn check_expected_astack(ref engine: Engine<EngineTransaction>, expected: Span<ByteArray>) {
    let astack = engine.get_astack();
    assert!(astack == expected, "Astack is not as expected");
}

pub fn mock_transaction_input_with(
    outpoint: EngineOutPoint, script_sig: ByteArray, witness: Array<ByteArray>, sequence: u32,
) -> EngineTransactionInput {
    let mut compiler = CompilerImpl::new();
    let script_sig = compiler.compile(script_sig).unwrap();
    EngineTransactionInput {
        previous_outpoint: outpoint,
        signature_script: script_sig,
        witness: witness,
        sequence: sequence,
    }
}

pub fn mock_transaction_input(script_sig: ByteArray) -> EngineTransactionInput {
    let outpoint: EngineOutPoint = EngineOutPoint {
        txid: 0xb7994a0db2f373a29227e1d90da883c6ce1cb0dd2d6812e4558041ebbbcfa54b, vout: 0,
    };
    mock_transaction_input_with(outpoint, script_sig, ArrayTrait::new(), 0xffffffff)
}

pub fn mock_transaction_output_with(
    value: i64, script_pubkey: ByteArray,
) -> EngineTransactionOutput {
    EngineTransactionOutput { value: value, publickey_script: script_pubkey }
}

pub fn mock_transaction_output() -> EngineTransactionOutput {
    let output_script_u256: u256 = 0x76a914b3e2819b6262e0b1f19fc7229d75677f347c91ac88ac;
    let mut output_script: ByteArray = "";
    output_script.append_word(output_script_u256.high.into(), 9);
    output_script.append_word(output_script_u256.low.into(), 16);
    mock_transaction_output_with(15000, output_script)
}

pub fn mock_transaction_with(
    version: i32,
    tx_inputs: Array<EngineTransactionInput>,
    tx_outputs: Array<EngineTransactionOutput>,
    locktime: u32,
) -> EngineTransaction {
    EngineTransaction {
        version: version,
        transaction_inputs: tx_inputs,
        transaction_outputs: tx_outputs,
        locktime: locktime,
        txid: 0,
        utxos: array![],
    }
}

// Mock simple transaction '1d5308ff12cb6fdb670c3af673a6a1317e21fa14fc863d5827f9d704cd5e14dc'
pub fn mock_transaction(script_sig: ByteArray) -> EngineTransaction {
    let mut inputs = ArrayTrait::<EngineTransactionInput>::new();
    inputs.append(mock_transaction_input(script_sig));
    let mut outputs = ArrayTrait::<EngineTransactionOutput>::new();
    outputs.append(mock_transaction_output());
    return mock_transaction_with(1, inputs, outputs, 0);
}

// Mock transaction '1d5308ff12cb6fdb670c3af673a6a1317e21fa14fc863d5827f9d704cd5e14dc'
// Legacy P2PKH
pub fn mock_transaction_legacy_p2pkh(script_sig: ByteArray) -> EngineTransaction {
    mock_transaction(script_sig)
}

// Mock transaction '949591ad468cef5c41656c0a502d9500671ee421fadb590fbc6373000039b693'
// Legacy P2MS
pub fn mock_transaction_legacy_p2ms(script_sig: ByteArray) -> EngineTransaction {
    let outpoint: EngineOutPoint = EngineOutPoint {
        txid: 0x10a5fee9786a9d2d72c25525e52dd70cbd9035d5152fac83b62d3aa7e2301d58, vout: 0,
    };
    let mut inputs = ArrayTrait::<EngineTransactionInput>::new();
    inputs.append(mock_transaction_input_with(outpoint, script_sig, ArrayTrait::new(), 0xffffffff));

    let mut outputs = ArrayTrait::<EngineTransactionOutput>::new();
    let output_script_u256: u256 = 0x76a914971802edf585cdbc4e57017d6e5142515c1e502888ac;
    let mut output_script: ByteArray = "";
    output_script.append_word(output_script_u256.high.into(), 9);
    output_script.append_word(output_script_u256.low.into(), 16);
    outputs.append(mock_transaction_output_with(1680000, output_script));

    return mock_transaction_with(1, inputs, outputs, 0);
}

pub fn mock_witness_transaction() -> EngineTransaction {
    let outpoint_0: EngineOutPoint = EngineOutPoint {
        txid: 0xac4994014aa36b7f53375658ef595b3cb2891e1735fe5b441686f5e53338e76a, vout: 1,
    };
    let transaction_input_0: EngineTransactionInput = EngineTransactionInput {
        previous_outpoint: outpoint_0,
        signature_script: "",
        witness: ArrayTrait::<ByteArray>::new(),
        sequence: 0xffffffff,
    };
    let mut transaction_inputs: Array<EngineTransactionInput> = ArrayTrait::<
        EngineTransactionInput,
    >::new();
    transaction_inputs.append(transaction_input_0);
    let script_u256: u256 = 0x76a914ce72abfd0e6d9354a660c18f2825eb392f060fdc88ac;
    let mut script_byte: ByteArray = "";

    script_byte.append_word(script_u256.high.into(), 9);
    script_byte.append_word(script_u256.low.into(), 16);

    let output_0: EngineTransactionOutput = EngineTransactionOutput {
        value: 15000, publickey_script: script_byte,
    };
    let mut transaction_outputs: Array<EngineTransactionOutput> = ArrayTrait::<
        EngineTransactionOutput,
    >::new();
    transaction_outputs.append(output_0);

    EngineTransaction {
        version: 2,
        transaction_inputs: transaction_inputs,
        transaction_outputs: transaction_outputs,
        locktime: 0,
        txid: 0,
        utxos: array![],
    }
}

// Mock transaction with specified 'locktime' and with the 'sequence' field set to locktime
pub fn mock_transaction_legacy_locktime(script_sig: ByteArray, locktime: u32) -> EngineTransaction {
    let mut inputs = ArrayTrait::<EngineTransactionInput>::new();
    let outpoint = EngineOutPoint { txid: 0, vout: 0 };
    let input = mock_transaction_input_with(outpoint, script_sig, ArrayTrait::new(), 0xfffffffe);
    inputs.append(input);
    let outputs = ArrayTrait::<EngineTransactionOutput>::new();
    return mock_transaction_with(1, inputs, outputs, locktime);
}

// Mock transaction version 2 with the specified 'sequence'
pub fn mock_transaction_legacy_sequence_v2(
    script_sig: ByteArray, sequence: u32,
) -> EngineTransaction {
    let mut inputs = ArrayTrait::<EngineTransactionInput>::new();
    let outpoint = EngineOutPoint { txid: 0, vout: 0 };
    let input = mock_transaction_input_with(outpoint, script_sig, ArrayTrait::new(), sequence);
    inputs.append(input);
    let outputs = ArrayTrait::<EngineTransactionOutput>::new();
    return mock_transaction_with(2, inputs, outputs, 0);
}

//find last push_data opcode in a bytearray
pub fn find_last_index(sig: ByteArray) -> u32 {
    let mut i = sig.len() - 1;
    loop {
        if 1 < sig[i] && sig[i] < 75 {
            break;
        }
        i -= 1;

        if (i == 0) {
            break;
        }
    };
    return i + 1;
}
