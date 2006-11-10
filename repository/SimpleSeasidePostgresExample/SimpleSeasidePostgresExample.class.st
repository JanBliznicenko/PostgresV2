Class {
	#name : #SimpleSeasidePostgresExample,
	#superclass : #WAComponent,
	#instVars : [
		'sql',
		'result',
		'showTable'
	],
	#classVars : [
		'PG'
	],
	#category : #SimpleSeasidePostgresExample
}

{ #category : #testing }
SimpleSeasidePostgresExample class >> canBeRoot [
	
	^ true
]

{ #category : #accessing }
SimpleSeasidePostgresExample class >> clearConnection [
	PG notNil
		ifTrue: [PG terminate.
			PG := nil]
]

{ #category : #accessing }
SimpleSeasidePostgresExample class >> dbConnection [
	PG isNil
		ifTrue: [PG := PGConnection new.
			PG connectionArgs: self dbConnectionArgs.
			PG trace: 3.
			PG startup].
	^ PG
]

{ #category : #accessing }
SimpleSeasidePostgresExample class >> dbConnectionArgs [
	^ PGConnectionArgs
		hostname: 'localhost'
		portno: 5432
		databaseName: 'panda'
		userName: 'ledger'
		password: 'pinky'
]

{ #category : #initialization }
SimpleSeasidePostgresExample class >> initialize [
	"self initialize"
	| app |
	app := (self registerAsApplication: 'sqsql') preferenceAt: #sessionExpirySeconds put: 8 * 60 * 60;
				 yourself.
"	app libraries add: ShoreStandardStyles.
	app libraries add: ShoreStandardScripts.
"	
]

{ #category : #executing }
SimpleSeasidePostgresExample >> execute [
	result := self class dbConnection execute: sql
]

{ #category : #rendering }
SimpleSeasidePostgresExample >> pageTitle [
	^'Simple Query' translated
]

{ #category : #rendering }
SimpleSeasidePostgresExample >> renderContentOn: html [ 
	html
		form: [html text: 'Query:'.
			html break.
			(html textArea) columns: 50; rows: 5;  on: #sql of: self.
			html break.
			html text: 'Table'.
			html checkbox on: #showTable of: self.
			html break.
			html submitButton
				callback: [self execute];
				 text: 'Execute'].
	self result isNil
		ifFalse: [self renderResult: self result on: html]
]

{ #category : #rendering }
SimpleSeasidePostgresExample >> renderResult: aPGResult on: html [
	aPGResult resultSets do: [:each | self renderResultSet: each on:html]
]

{ #category : #rendering }
SimpleSeasidePostgresExample >> renderResultSet: aPGResultSet on: html [
	(showTable isNil or: [showTable])
		ifTrue: [self renderResultSetAsTable: aPGResultSet on: html]
		ifFalse: [self renderResultSetAsText: aPGResultSet on: html]
]

{ #category : #rendering }
SimpleSeasidePostgresExample >> renderResultSetAsTable: aPGResultSet on: html [ 
	html table border: '1';
		
		with: [html
				tableRow with: [aPGResultSet rowDescription columnDescriptions
						do: [:each | html
								tableHeading: [html text: each fieldName]]].
			aPGResultSet rows
				do: [:row | html
						tableRow with: [row rawData
								do: [:data | html
										tableData with: [html text: data]]]]]
]

{ #category : #rendering }
SimpleSeasidePostgresExample >> renderResultSetAsText: aPGResultSet on: html [
	| stream |
	stream := ReadWriteStream on: String new.
	aPGResultSet displayResultSetOn: stream.
	html preformatted: stream contents.

]

{ #category : #accessing }
SimpleSeasidePostgresExample >> result [
	"Answer the value of result"

	^ result
]

{ #category : #accessing }
SimpleSeasidePostgresExample >> result: anObject [
	"Set the value of result"

	result _ anObject
]

{ #category : #accessing }
SimpleSeasidePostgresExample >> showTable [
	"Answer the value of showTable"

	^ showTable
]

{ #category : #accessing }
SimpleSeasidePostgresExample >> showTable: anObject [
	"Set the value of showTable"

	showTable _ anObject
]

{ #category : #accessing }
SimpleSeasidePostgresExample >> sql [
	"Answer the value of sql"

	^ sql
]

{ #category : #accessing }
SimpleSeasidePostgresExample >> sql: anObject [
	"Set the value of sql"

	sql _ anObject
]
