Extension { #name : #String }

{ #category : #'*ImageExtensions' }
String >> asCamelCase [

	^self asLowercase subStrings
		inject: ''
		into: [:value :each | value, each capitalized].

]

{ #category : #'*ImageExtensions' }
String >> asInstVarName [
	| parts answer |

	answer := ''.
	parts := self subStrings.
	parts withIndexDo: [:each :i | answer := i > 1 ifTrue: [answer, each capitalized] ifFalse: [answer, each withFirstCharacterDownshifted]].
	^answer
]

{ #category : #'*ImageExtensions' }
String >> asNameUsingUnderscore [
	| s |

	"^(self copyReplacing: $  withObject: $_) asUppercase"
	s := self copy.
	1 to: s size do: [:i | (s at: i) = Character space ifTrue: [s at: i put: $_]].
	^s
]

{ #category : #'*ImageExtensions' }
String >> breezeOoaNameToUnderscoreName [
	"Convert name such as 'foo bar baz' to 'foo_bar_baz'"
	| s |

	"^(self copyReplacing: $  withObject: $_) asUppercase"
	s := self copy withBlanksTrimmed.
	1 to: s size do: [:i | (s at: i) = Character space ifTrue: [s at: i put: $_]].
	^s
]

{ #category : #'*ImageExtensions' }
String >> breezeUnderscoreNameToOoaName [
	"Convert name such as 'foo_bar_baz' to 'foo bar baz'"
	| s |

	"^(self copyReplacing: $_ withObject: $ )"
	s := self copy.
	1 to: s size do: [:i | (s at: i) = $_ ifTrue: [s at: i put: Character space]].
	^s withBlanksTrimmed

]

{ #category : #'*ImageExtensions' }
String >> split: ch [ 
	| pieces i prev |
	pieces := OrderedCollection new.
	i := 0.
	[(i := self indexOf: ch startingAt: (prev := i + 1)) == 0] whileFalse: 
			[prev < i ifTrue: [pieces add: (self copyFrom: prev to: i - 1)].
			prev == i ifTrue: [pieces add: String new]].
	prev <= self size 
		ifTrue: [pieces add: (self copyFrom: prev to: self size)].
	(self isEmpty not and: [self last = ch]) ifTrue: [pieces add: String new].
	^pieces
]

{ #category : #'*ImageExtensions' }
String >> sqlString [
	^ self printString

]
