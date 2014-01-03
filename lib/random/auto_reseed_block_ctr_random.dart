library cipher.random.auto_reseed_block_ctr_random;

import "dart:typed_data";

import "package:cipher/api.dart";
import "package:cipher/random/block_ctr_random.dart";
import "package:cipher/params/parameters_with_iv.dart";
import "package:cipher/params/key_parameter.dart";


/**
 * An implementation of [SecureRandom] that uses a [BlockCipher] with CTR mode to generate random values and automatically
 * self reseeds itself after each request for data, in order to achieve forward security. See section 4.1 of the paper:
 * Practical Random Number Generation in Software (by John Viega).
 */
class AutoReseedBlockCtrRandom implements SecureRandom {

	BlockCtrRandom _delegate;

	var _inAutoReseed = false;
	var _autoReseedKeyLength;

  String get algorithmName => "${_delegate.cipher.algorithmName}/CTR/AUTO_RESEED_PRNG";

	AutoReseedBlockCtrRandom(BlockCipher cipher) {
		_delegate = new BlockCtrRandom(cipher);
	}

  void init(ParametersWithIV<KeyParameter> params) {
		_autoReseedKeyLength = params.parameters.key.length;
		_delegate.init( params );
  }

  Uint8 nextUint8() => _autoReseedIfNeededAfter( () {
		return _delegate.nextUint8();
  });

  Uint16 nextUint16() => _autoReseedIfNeededAfter( () {
		return _delegate.nextUint16();
	});

  Uint32 nextUint32() => _autoReseedIfNeededAfter( () {
		return _delegate.nextUint32();
	});

  BigInteger nextBigInteger( int bitLength ) => _autoReseedIfNeededAfter( () {
		return _delegate.nextBigInteger(bitLength);
	});

	Uint8List nextBytes( int count ) => _autoReseedIfNeededAfter( () {
		return _delegate.nextBytes(count);
	});

  dynamic _autoReseedIfNeededAfter( dynamic closure ) {
		if( _inAutoReseed ) {
			return closure();
		} else {
			_inAutoReseed = true;
			var ret = closure();
			_doAutoReseed();
			_inAutoReseed = false;
			return ret;
		}
  }

  void _doAutoReseed() {
		var newKey = nextBytes(_autoReseedKeyLength);
		var newIV = nextBytes(_delegate.cipher.blockSize);
		var keyParam = new KeyParameter(newKey);
		var params = new ParametersWithIV(keyParam, newIV);
		_delegate.init( params );
  }

}
