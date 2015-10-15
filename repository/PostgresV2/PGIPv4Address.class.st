Class {
	#name : #PGIPv4Address,
	#superclass : #Object,
	#instVars : [
		'first',
		'second',
		'third',
		'fourth'
	],
	#category : #PostgresV2
}

{ #category : #'instance creation' }
PGIPv4Address class >> first: aFirstByte second: aSecondByte third: aThirdByte fourth: aFourthByte [
	^self new
		first: aFirstByte;
		second: aSecondByte;
		third: aThirdByte;
		fourth: aFourthByte;
		yourself
]

{ #category : #'instance creation' }
PGIPv4Address class >> fromString: aString [
	| parts |
	parts := aString subStrings: '.'.
	^self
		first: parts first asNumber
		second: parts second asNumber
		third: parts third asNumber
		fourth: parts fourth asNumber
]

{ #category : #comparing }
PGIPv4Address >> = other [
	^(other isKindOf: PGIPv4Address)
		and: [ self first = other first ]
		and: [ self second = other second ]
		and: [ self third = other third ]
		and: [ self fourth = other fourth ]
]

{ #category : #converting }
PGIPv4Address >> asSqlString [
	^String streamContents: [ :stream |
		stream print: self first.
		stream nextPut: $..
		stream print: self second.
		stream nextPut: $..
		stream print: self third.
		stream nextPut: $..
		stream print: self fourth.]
]

{ #category : #enumerating }
PGIPv4Address >> do: aBlock [
	self first asString do: [:each | 
		aBlock value: each asCharacter ].
	aBlock value: '.' asCharacter .
	self second asString do: [:each | 
		aBlock value: each asCharacter ].
	aBlock value: '.' asCharacter.
	self third asString do: [:each | 
		aBlock value: each asCharacter ].
	aBlock value: '.' asCharacter.
	self fourth asString do: [:each | 
		aBlock value: each asCharacter ].
]

{ #category : #accessing }
PGIPv4Address >> first [
	^first
]

{ #category : #accessing }
PGIPv4Address >> first: anObject [
	first := anObject
]

{ #category : #accessing }
PGIPv4Address >> fourth [
	^fourth
]

{ #category : #accessing }
PGIPv4Address >> fourth: anObject [
	fourth := anObject
]

{ #category : #comparing }
PGIPv4Address >> hash [
	^((self first << 24
		bitOr: self second << 16)
		bitOr: self third << 8)
		bitOr: self fourth
]

{ #category : #accessing }
PGIPv4Address >> second [
	^second
]

{ #category : #accessing }
PGIPv4Address >> second: anObject [
	second := anObject
]

{ #category : #accessing }
PGIPv4Address >> third [
	^third
]

{ #category : #accessing }
PGIPv4Address >> third: anObject [
	third := anObject
]
