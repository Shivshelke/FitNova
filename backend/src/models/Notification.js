/**
 * Notification Model
 * Stores scheduled and sent notification records for users
 */

const mongoose = require('mongoose');

const notificationSchema = new mongoose.Schema(
  {
    user: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'User',
      required: true,
    },

    // Notification category
    type: {
      type: String,
      enum: ['workout_reminder', 'water_reminder', 'goal_alert', 'achievement', 'general'],
      required: true,
    },

    title: {
      type: String,
      required: true,
    },

    message: {
      type: String,
      required: true,
    },

    // When to send this notification
    scheduledTime: {
      type: Date,
      default: null,
    },

    // Has it been read/dismissed?
    isRead: {
      type: Boolean,
      default: false,
    },

    // Has it been sent (for push notification tracking)?
    isSent: {
      type: Boolean,
      default: false,
    },

    // Repeat pattern
    repeatPattern: {
      type: String,
      enum: ['none', 'daily', 'weekly'],
      default: 'none',
    },
  },
  { timestamps: true }
);

notificationSchema.index({ user: 1, isRead: 1 });

const Notification = mongoose.model('Notification', notificationSchema);
module.exports = Notification;
