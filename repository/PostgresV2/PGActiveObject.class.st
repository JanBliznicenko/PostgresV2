Class {
	#name : #PGActiveObject,
	#superclass : #Object,
	#instVars : [
		'trace',
		'state',
		'events'
	],
	#classInstVars : [
		'stateTransitionTable'
	],
	#category : #PostgresV2
}

{ #category : #stt }
PGActiveObject class >> buildStateTransitionTable [

	^ Dictionary new

]

{ #category : #stt }
PGActiveObject class >> resetStateTransitionTable [

	stateTransitionTable := nil

]

{ #category : #stt }
PGActiveObject class >> stateTransitionTable [

	stateTransitionTable == nil ifTrue: [stateTransitionTable := self buildStateTransitionTable].
	^ stateTransitionTable

]

{ #category : #'private-sa' }
PGActiveObject >> generateEvent: event to: receiver [

	^self == receiver
		ifTrue: [self processEvent: event]
		ifFalse: [receiver queueEvent: event].

]

{ #category : #'initialize/release' }
PGActiveObject >> initialize [

	state := #Created.
	events := OrderedCollection new.
	^self

]

{ #category : #trace }
PGActiveObject >> log: where text: text [

	self logInfo: where, ': ', text.

]

{ #category : #trace }
PGActiveObject >> logIdString [

	^ self class name, '(', self hash printString, ')'.

]

{ #category : #trace }
PGActiveObject >> logInfo: text [

	Transcript
		nextPut: $[;
		nextPutAll: self logIdString;
		nextPut: $];
		space;
		nextPutAll: text;
		cr;
		flush.

]

{ #category : #'private-sa' }
PGActiveObject >> nextEvent [

	^ #CantHappen

]

{ #category : #'private-sa' }
PGActiveObject >> processEvent: event [

	| nextState eventName eventNameString traceText |

	eventName := event isSymbol ifTrue: [event] ifFalse: [event eventName].
	nextState := (self stateTransitionTable at: state)
		at: eventName
		ifAbsent: [ #CantHappen ].

	trace >= 8 ifTrue: [
		eventNameString := event isSymbol ifTrue: [event asString] ifFalse: [event eventName].
		traceText := nextState = #EventIgnored
			ifTrue: [ state asString, ' IGNORE ', eventNameString ]
			ifFalse: [ state asString, '-->', nextState asString, ' on ', eventNameString ].
		self log: 'processEvent' text: traceText.
	].

	nextState = #EventIgnored
		ifFalse: [
			state := nextState.
			self perform: ('st', state asString, ':') asSymbol with: event.
		].

]

{ #category : #'private-sa' }
PGActiveObject >> queueEvent: event [

	events addLast: event.

]

{ #category : #'private-sa' }
PGActiveObject >> saProcessEventsUntil: newStates [

	[
		[events size > 0] whileTrue: [
			self processEvent: events removeFirst.
		].
		(newStates includes: state) 
			ifFalse: [self generateEvent: self nextEvent to: self].
		(newStates includes: state) not
	] whileTrue.

]

{ #category : #'private-sa' }
PGActiveObject >> stCantHappen: event [
	"Handle a defective state machine."

	self error: self class name, ' has a defective state machine'.

]

{ #category : #'private-sa' }
PGActiveObject >> stateTransitionTable [

	^ self class stateTransitionTable

]

{ #category : #trace }
PGActiveObject >> trace [
	^trace
]

{ #category : #trace }
PGActiveObject >> trace: anInteger [
	trace := anInteger
]
