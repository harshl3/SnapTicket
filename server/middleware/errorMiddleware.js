const errorHandler = (err, req, res, next) => {
  // Log the stack trace internally for debugging
  console.error(err.stack || err.message);

  let statusCode = res.statusCode === 200 ? 500 : res.statusCode;
  let message = err.message;

  // Handle Mongoose CastError (Invalid ObjectIds)
  if (err.name === 'CastError' && err.kind === 'ObjectId') {
    statusCode = 400;
    message = 'Invalid resource ID format';
  }

  // Handle Mongoose ValidationError
  if (err.name === 'ValidationError') {
    statusCode = 400;
    message = Object.values(err.errors).map(val => val.message).join(', ');
  }

  // Handle Duplicate key database error
  if (err.code === 11000) {
    statusCode = 400;
    message = 'Duplicate database record found';
  }

  res.status(statusCode).json({
    success: false,
    message: message || 'Internal Server Error'
  });
};

module.exports = errorHandler;
