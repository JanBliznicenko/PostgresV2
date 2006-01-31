Class {
	#name : #PGNotificationSubscriber,
	#superclass : #PGActiveObject,
	#category : #PostgresV2
}

{ #category : #api }
PGNotificationSubscriber >> receive: notice from: aConnection [

	self logInfo: notice printString, ' received from ', aConnection logIdString.

]
