Extension { #name : #SequenceableCollection }

{ #category : #'*ImageExtensions' }
SequenceableCollection >> joinWith: separator [
	"Answer a string with elements converted to strings and separated by separator."

	| ws |
	ws := WriteStream on: (String new: 100).
	self withIndexDo: [:each :i |
		ws nextPutAll: each asString.
		i < self size ifTrue: [ ws nextPutAll: separator ].
	].
	^ws contents
]
