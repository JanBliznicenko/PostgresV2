Class {
	#name : #PGNotificationResponse,
	#superclass : #PGPacket,
	#instVars : [
		'processId',
		'conditionName'
	],
	#category : #PostgresV2
}

{ #category : #accessing }
PGNotificationResponse >> conditionName [
	"Answer the value of conditionName"

	^ conditionName
]

{ #category : #accessing }
PGNotificationResponse >> conditionName: anObject [
	"Set the value of conditionName"

	conditionName := anObject
]

{ #category : #accessing }
PGNotificationResponse >> eventName [
	^#NotificationResponse
]

{ #category : #accessing }
PGNotificationResponse >> processId [
	"Answer the value of processId"

	^ processId
]

{ #category : #accessing }
PGNotificationResponse >> processId: anObject [
	"Set the value of processId"

	processId := anObject
]

{ #category : #receiving }
PGNotificationResponse >> receiveFrom: connection [

	processId := self readInt32From: connection.
	conditionName := self readStringFrom: connection.

]
