package config

import (
	"errors"
	"time"
)

const (
	// Server Port
	ServerPort = ":8083"

	// log related settings
	LogFilePath = "/data/logs/jrpc/api.log"
	LogPerm     = 0755

	// HTTP request timeout
	HTTPRequestTimeout = time.Second * 3
	TimeFormatRFC2822  = "Mon, 02 Jan 2006 15:04:05 -0700"

	// Maximum number of retry attempt while trying to redirect
	RedirectCount = 10

	// Cache expiration
	CacheExpire = time.Minute * 5
)

var (
	ErrInvalidHost             = errors.New("Request failed due to invalid Host")
	ErrInvalidURL              = errors.New("Request failed due to invalid URL")
	ErrInvalidRedirectLocation = errors.New("Invalid redirect destination specified")
	ErrTooManyRedirection      = errors.New("Too many redirects")

	ErrSystem       = "system_error"
	ErrMsgSystem    = "Application is temporarily unavailable, please try again later."
	ErrInvalidParam = "invalid_parameter"
	ErrMsgParam     = "Request parameter ' % s ' is triggering an error"
)
