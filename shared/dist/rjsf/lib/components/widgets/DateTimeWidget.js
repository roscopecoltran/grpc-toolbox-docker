"use strict";

Object.defineProperty(exports, "__esModule", {
  value: true
});

var _extends = Object.assign || function (target) { for (var i = 1; i < arguments.length; i++) { var source = arguments[i]; for (var key in source) { if (Object.prototype.hasOwnProperty.call(source, key)) { target[key] = source[key]; } } } return target; };

var _react = require("react");

var _react2 = _interopRequireDefault(_react);

var _propTypes = require("prop-types");

var _propTypes2 = _interopRequireDefault(_propTypes);

function _interopRequireDefault(obj) { return obj && obj.__esModule ? obj : { default: obj }; }

function fromJSONDate(jsonDate) {
  return jsonDate ? jsonDate.slice(0, 19) : "";
}

function toJSONDate(dateString) {
  if (dateString) {
    return new Date(dateString).toJSON();
  }
}

function DateTimeWidget(props) {
  var value = props.value,
      _onChange = props.onChange,
      BaseInput = props.registry.widgets.BaseInput;

  return _react2.default.createElement(BaseInput, _extends({
    type: "datetime-local"
  }, props, {
    value: fromJSONDate(value),
    onChange: function onChange(value) {
      return _onChange(toJSONDate(value));
    }
  }));
}

if (process.env.NODE_ENV !== "production") {
  DateTimeWidget.propTypes = {
    value: _propTypes2.default.string
  };
}

exports.default = DateTimeWidget;