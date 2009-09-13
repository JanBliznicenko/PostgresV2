Class {
	#name : #PGAsciiRow,
	#superclass : #PGPacket,
	#instVars : [
		'description',
		'nullFields',
		'rawData'
	],
	#category : #PostgresV2
}

{ #category : #'instance creation' }
PGAsciiRow class >> description: aRowDescription [

	^self new
		description: aRowDescription;
		yourself.

]

{ #category : #'instance creation' }
PGAsciiRow class >> new [

	^self basicNew initialize.

]

{ #category : #accessing }
PGAsciiRow >> data [

	| converters converter data |

	converters := description resultSet result connection fieldConverters.
	data := OrderedCollection new.
	rawData with: description columnDescriptions do: [:each :aColumnDescription |
		data addLast: (
			each isNil
				ifTrue: [nil]
				ifFalse: [
					converter := converters at: aColumnDescription typeOid ifAbsent: [nil].
					converter isNil ifTrue: [ each ] ifFalse: [ converter value: each ].
				]).
	].
	^data

]

{ #category : #accessing }
PGAsciiRow >> dataKeyedByFieldName [

	| d |

	d := Dictionary new.
	self data with: description columnDescriptions do: [:each :aColumnDescription |
		d at: aColumnDescription fieldName put: each.
	].
	^ d

]

{ #category : #accessing }
PGAsciiRow >> dataRow [

	| converters converter data dictionary index |

	converters := description resultSet result connection fieldConverters.
	dictionary := description columnDescriptionDictionary.
	data := PGDataRow for: dictionary.
	index := 0.
	rawData with: description columnDescriptions do: [ :each :aColumnDescription |
		data
			at: (index := index + 1)
			put: (
				each ifNotNil: [
					(converter := converters at: aColumnDescription typeOid ifAbsent: nil)
						ifNil: [ each ]
						ifNotNil: [ converter reentrant value: each ] ]) ].
	^data

]

{ #category : #accessing }
PGAsciiRow >> description: aRowDescription [
	description := aRowDescription.

]

{ #category : #printing }
PGAsciiRow >> displayOn: aStream [

	rawData withIndexDo: [:each :i |
		aStream nextPutAll: (each == nil ifTrue: ['0'] ifFalse: [each]).
		i < rawData size ifTrue: [aStream space].
	].

]

{ #category : #accessing }
PGAsciiRow >> eventName [
	^#AsciiRow
]

{ #category : #initialize }
PGAsciiRow >> initialize [

	rawData := OrderedCollection new.
	^self
]

{ #category : #printing }
PGAsciiRow >> printOn: aStream [

	super printOn: aStream.
	aStream nextPutAll: '('.
	rawData do: [:each | each printOn: aStream. aStream nextPut: $,].
	aStream nextPutAll: ')'.

]

{ #category : #accessing }
PGAsciiRow >> rawData [
	^ rawData
]

{ #category : #receiving }
PGAsciiRow >> receiveFrom: connection [

	| ncol |

	description := connection result rowDescription.
	ncol := description numberOfColumns.
	nullFields := self readBitmap: ncol from: connection.
	0 to: ncol - 1 do: [:i |
		((nullFields at: (i // 8) + 1) bitAnd: (2r10000000 bitShift: (i \\ 8) negated)) > 0
			ifTrue: [rawData add: (self readFieldFrom: connection)]
			ifFalse: [rawData add: nil].
	].

]
