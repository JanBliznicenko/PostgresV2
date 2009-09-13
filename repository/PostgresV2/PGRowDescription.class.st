Class {
	#name : #PGRowDescription,
	#superclass : #PGPacket,
	#instVars : [
		'resultSet',
		'numberOfColumns',
		'columnDescriptions',
		'columnDescriptionDictionary'
	],
	#category : #PostgresV2
}

{ #category : #'instance creation' }
PGRowDescription class >> new [

	^self basicNew initialize.

]

{ #category : #'as yet unclassified' }
PGRowDescription >> columnDescriptionDictionary [

	^columnDescriptionDictionary ifNil: [
		columnDescriptionDictionary := IdentityDictionary new.
		columnDescriptions doWithIndex: [ :each :i |
			columnDescriptionDictionary at: each fieldName asSymbol put: i ].
		columnDescriptionDictionary ]
]

{ #category : #accessing }
PGRowDescription >> columnDescriptions [
	^ columnDescriptions
]

{ #category : #printing }
PGRowDescription >> displayOn: aStream [

	columnDescriptions withIndexDo: [:each :i |
		each displayOn: aStream.
		i < columnDescriptions size ifTrue: [aStream space].
	].

]

{ #category : #accessing }
PGRowDescription >> eventName [
	^#RowDescription
]

{ #category : #initialize }
PGRowDescription >> initialize [

	numberOfColumns := 0.
	columnDescriptions := OrderedCollection new.

]

{ #category : #accessing }
PGRowDescription >> numberOfColumns [
	^numberOfColumns
]

{ #category : #printing }
PGRowDescription >> printOn: aStream [

	super printOn: aStream.
	aStream nextPutAll: '('; cr.
	columnDescriptions do: [:each | each printOn: aStream. aStream cr].
	aStream nextPutAll: ')'.

]

{ #category : #receiving }
PGRowDescription >> receiveFrom: connection [

	numberOfColumns := self readInt16From: connection.
	1 to: numberOfColumns do: [:i |
		columnDescriptions add: (PGColumnDescription new receiveFrom: connection; yourself).
	].

]

{ #category : #accessing }
PGRowDescription >> resultSet [
	^ resultSet
]

{ #category : #accessing }
PGRowDescription >> resultSet: anObject [
	resultSet := anObject
]
