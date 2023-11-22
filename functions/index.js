const logger = require("firebase-functions/logger");
const functions = require("firebase-functions");

exports.logCreations = functions.firestore.document("todos/{todoId}").onCreate((snapshot) => {
  logger.info("Todo created with ID", snapshot.id)

  return snapshot;
})

exports.logUpdates = functions.firestore.document("todos/{todoId}").onUpdate((snapshot) => {
  logger.info("Todo updated with ID", snapshot.after.id)

  return snapshot;
})

exports.logDeletions = functions.firestore.document("todos/{todoId}").onDelete((snapshot) => {
  logger.warn("Todo deleted with ID", snapshot.id)

  return snapshot;
})