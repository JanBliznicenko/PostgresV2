Extension { #name : #OrderedCollection }

{ #category : #'*PostgresV2' }
OrderedCollection >> asSqlString [
	^ String streamContents: [:stream |
			stream nextPutAll: ' {'.
			self
				do: [:each | stream nextPutAll: each asSqlString ] 
				separatedBy: [ stream nextPutAll: ', ' ].
			stream nextPutAll: '} '.
		]
]
