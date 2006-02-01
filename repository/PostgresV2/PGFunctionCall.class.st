Class {
	#name : #PGFunctionCall,
	#superclass : #PGPacket,
	#instVars : [
		'oid',
		'arguments'
	],
	#category : #PostgresV2
}

{ #category : #'instance creation' }
PGFunctionCall class >> oid: anInteger arguments: aCollection [
	"Return a new instance of the receiver.

	'anInteger' specifies the object ID of the function to call. The object ID is a site specific PostgreSQL value.
	'aCollection' contains the arguments of the function call. It should contain String values, which may have non-printable characters (i.e. values 0..255).
	"

	^ self new setOid: anInteger arguments: aCollection

]

{ #category : #accessing }
PGFunctionCall >> arguments [
	^arguments
]

{ #category : #accessing }
PGFunctionCall >> arguments: value [
	arguments := value
]

{ #category : #accessing }
PGFunctionCall >> oid [
	^oid
]

{ #category : #accessing }
PGFunctionCall >> oid: value [
	oid := value
]

{ #category : #printing }
PGFunctionCall >> printOn: aStream [

	super printOn: aStream.
	aStream
		nextPutAll: '(';
		nextPutAll: 'oid='; nextPutAll: oid printString;
		nextPutAll: ',arguments='; nextPutAll: arguments printString;
		nextPutAll: ')'
]

{ #category : #'private-initialize' }
PGFunctionCall >> setOid: anInteger arguments: anArray [

	oid := anInteger.
	arguments := anArray
]

{ #category : #printing }
PGFunctionCall >> writeOn: aStream [

	self writeByte: $F on: aStream.
	self writeString: '' on: aStream.
	self writeInt32: self oid on: aStream.
	self writeInt32: self arguments size on: aStream.
	self arguments do: [:arg |
		self writeInt32: arg size on: aStream.
		arg do: [:b | self writeByte: (Character value: b) on: aStream].
	]
]
