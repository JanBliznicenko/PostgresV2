Class {
	#name : #PGDataRow,
	#superclass : #Object,
	#type : #variable,
	#instVars : [
		'dictionary'
	],
	#category : #PostgresV2
}

{ #category : #'as yet unclassified' }
PGDataRow class >> for: aDictionary [

	^(self new: aDictionary size)
		dictionary: aDictionary;
		yourself
]

{ #category : #'as yet unclassified' }
PGDataRow >> atName: aSymbol [

	^self at: (dictionary at: aSymbol)
]

{ #category : #'as yet unclassified' }
PGDataRow >> atName: aSymbol ifAbsent: aBlock [

	^self at: (dictionary 
		at: aSymbol
		ifAbsent: [ ^aBlock value ])
]

{ #category : #accessing }
PGDataRow >> dictionary [
	
	^dictionary
]

{ #category : #'as yet unclassified' }
PGDataRow >> dictionary: anIdentityDictionary [

	dictionary := anIdentityDictionary 
]

{ #category : #'as yet unclassified' }
PGDataRow >> doesNotUnderstand: aMessage [

	^self at: (
		dictionary 
			at: aMessage selector
			ifAbsent: [ ^super doesNotUnderstand: aMessage ])
]

{ #category : #'as yet unclassified' }
PGDataRow >> indexOf: aSymbol [

	^dictionary at: aSymbol ifAbsent: 0
]

{ #category : #'as yet unclassified' }
PGDataRow >> name [

	^self atName: #name
]

{ #category : #'as yet unclassified' }
PGDataRow >> printOn: aStream [

	super printOn: aStream.
	aStream nextPut: $(.
	(dictionary associations
		sort: [ :a :b | a value < b value ])
		do: [ :assoc |
			aStream 
				nextPutAll: assoc key;
				nextPutAll: ': ';
				print: (self at: assoc value) ]
		separatedBy: [ aStream nextPutAll: ', ' ].
	aStream nextPut: $)
]
