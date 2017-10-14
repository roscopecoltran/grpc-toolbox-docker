package model

import (
	"encoding/json"
	"time"
)

type Error struct {
	Code      int       `json:"error_code"`
	TimeStamp time.Time `json:"time_stamp"`
	Message   string    `json:"message"`
	Type      string    `json:"error_type"`
	URI       string    `json:"uri"`
}

func (e Error) Error() string {
	return e.Message
}

func (e Error) JSON() []byte {
	v, err := json.Marshal(e)
	if err != nil {
		return nil
	}
	return v
}
