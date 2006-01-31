Class {
	#name : #PGNoticeResponse,
	#superclass : #PGAbstractStringResponse,
	#category : #PostgresV2
}

{ #category : #accessing }
PGNoticeResponse >> eventName [
	^#NoticeResponse
]
