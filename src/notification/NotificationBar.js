import React, { Component } from "react"
import { connect } from "react-redux"
import { MessageBar, MessageBarType } from "office-ui-fabric-react"
import { removeNotification, NotificationType } from "."

const messageBarTypeFor = (notificationType) => {
  switch (notificationType) {
    case NotificationType.ERROR: return MessageBarType.error
    default:                     return MessageBarType.info
  }
}

class NotificationBar extends Component {
  render() {
    return <ul className="message-bar">{
      this.props.notifications.map(notification => (
        <li key={notification.id}>
          <MessageBar
            messageBarType={messageBarTypeFor(notification.type)}
            onDismiss={() => this.props.dispatch(removeNotification(notification))}>
            {notification.message}
          </MessageBar>
        </li>
      ))
    }</ul>
  }
}

export default connect(
  state => ({
    notifications: state.notifications
  })
)(NotificationBar)
