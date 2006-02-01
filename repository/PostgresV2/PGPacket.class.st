Class {
	#name : #PGPacket,
	#superclass : #Object,
	#classVars : [
		'PacketClasses'
	],
	#category : #PostgresV2
}

{ #category : #'initialize-release' }
PGPacket class >> initialize [
	"PGPacket initialize"

	PacketClasses := IdentityDictionary new
		at: $K put: PGBackendKeyData;
		at: $R put: PGAuthentication;
		at: $C put: PGCompletedResponse;
		at: $G put: PGCopyInResponse;
		at: $H put: PGCopyOutResponse;
		at: $P put: PGCursorResponse;
		at: $I put: PGEmptyQueryResponse;
		at: $E put: PGErrorResponse;
		at: $V put: PGFunctionResultResponse;
		at: $N put: PGNoticeResponse;
		at: $A put: PGNotificationResponse;
		at: $Z put: PGReadyForQuery;
		at: $T put: PGRowDescription;
		at: $D put: PGAsciiRow;
		at: $B put: PGBinaryRow;
		yourself
]

{ #category : #factory }
PGPacket class >> newPacket: typeCode [
	| packetClass |

	packetClass := PacketClasses at: typeCode ifAbsent: [nil].
	^packetClass isNil
		ifTrue: [nil]
		ifFalse: [packetClass new]
]

{ #category : #accessing }
PGPacket >> eventName [
	^self subclassResponsibility
]

{ #category : #printing }
PGPacket >> printOn: aStream [

	aStream nextPutAll: self class name.

]

{ #category : #receiving }
PGPacket >> readBitmap: nbits from: connection [

	| nbytes bitmap |

	nbytes := (nbits + 7) // 8.
	bitmap := ByteArray new: nbytes.
	1 to: nbytes do: [:i |
		bitmap at: i put: connection next codePoint.
	].
	^bitmap

]

{ #category : #receiving }
PGPacket >> readByteN: n from: connection [

	| bytes |

	bytes := ByteArray new: n.
	1 to: n do: [:i | bytes byteAt: i put: connection next codePoint].
	^bytes
]

{ #category : #receiving }
PGPacket >> readFieldFrom: connection [

	| n tmp |

	n := (self readInt32From: connection) - 4.
	tmp := WriteStream on: String new.
	1 to: n do: [:i |
		tmp nextPut: connection next.
	].
	^tmp contents

]

{ #category : #receiving }
PGPacket >> readInt16From: connection [

	| value |

	value := connection next codePoint.
	value := (value bitShift: 8) bitOr: connection next codePoint.
	^value

]

{ #category : #receiving }
PGPacket >> readInt32From: connection [

	| value |

	value := connection next codePoint.
	value := (value bitShift: 8) bitOr: connection next codePoint.
	value := (value bitShift: 8) bitOr: connection next codePoint.
	value := (value bitShift: 8) bitOr: connection next codePoint.
	^value

]

{ #category : #receiving }
PGPacket >> readStringFrom: connection [

	| tmp ch |
	tmp := WriteStream on: String new.
	[ (ch := connection next) codePoint ~= 0 ] whileTrue: [
		tmp nextPut: ch.
	].
	^tmp contents


]

{ #category : #receiving }
PGPacket >> receiveFrom: connection [

	"Read nothing, by default"

]

{ #category : #sending }
PGPacket >> writeByte: aCharacter on: aStream [

	aStream
		nextPut: aCharacter;
		yourself.


]

{ #category : #sending }
PGPacket >> writeInt16: anInteger on: aStream [

	aStream
		nextPut: (Character value: ((anInteger bitShift: -1*8) bitAnd: 16rFF));
		nextPut: (Character value: ((anInteger bitShift: 0*8) bitAnd: 16rFF));
		yourself.

]

{ #category : #sending }
PGPacket >> writeInt32: anInteger on: aStream [

	aStream
		nextPut: (Character value: ((anInteger bitShift: -3*8) bitAnd: 16rFF));
		nextPut: (Character value: ((anInteger bitShift: -2*8) bitAnd: 16rFF));
		nextPut: (Character value: ((anInteger bitShift: -1*8) bitAnd: 16rFF));
		nextPut: (Character value: ((anInteger bitShift: 0*8) bitAnd: 16rFF));
		yourself.

]

{ #category : #sending }
PGPacket >> writeLimString: aString size: size on: aStream [

	aString isNil ifTrue: [
		size timesRepeat: [ aStream nextPut: (Character value: 0) ].
		^aStream.
	].

	aString size < size
		ifTrue: [
			aStream nextPutAll: aString.
			(size - aString size max: 0) timesRepeat: [ aStream nextPut: (Character value: 0) ].
		]
		ifFalse: [
			aStream nextPutAll: (aString copyFrom: 1 to: size).
		].

	^aStream.

]

{ #category : #sending }
PGPacket >> writeOn: aStream [

	self subclassResponsiblity

]

{ #category : #sending }
PGPacket >> writeString: aString on: aStream [

	aStream
		nextPutAll: aString;
		nextPut: (Character value: 0);
		yourself.


]
