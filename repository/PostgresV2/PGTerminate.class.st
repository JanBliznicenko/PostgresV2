Class {
	#name : #PGTerminate,
	#superclass : #PGPacket,
	#category : #PostgresV2
}

{ #category : #sending }
PGTerminate >> writeOn: aStream [

	self writeByte: $X on: aStream.

]
