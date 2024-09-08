/// The default timeout duration for HTTP requests.
///
/// This constant defines the maximum amount of time allowed for an HTTP request
/// to complete before it times out. If a request takes longer than this duration,
/// it will be terminated, and an error will be thrown.
///
/// The value is set to 30 seconds, which is generally sufficient for most API
/// calls, but can be adjusted if needed for specific use cases.
const Duration DEFAULT_REQUEST_TIMEOUT = Duration(seconds: 30);

/// The default timeout duration for establishing a connection.
///
/// This constant specifies the maximum time allowed for the initial connection
/// to be established with the server. If the connection cannot be made within
/// this timeframe, the request will fail with a connection timeout error.
///
/// Like the request timeout, this is also set to 30 seconds, providing a
/// balance between allowing enough time for connections in various network
/// conditions and failing quickly in case of connectivity issues.
const Duration DEFAULT_CONNECT_TIMEOUT = Duration(seconds: 30);

/// The header key used to identify local middleware.
///
/// This constant defines the HTTP header key that is used to indicate that
/// a request has been processed by local middleware. It allows for tracking
/// and managing the flow of requests through various middleware components
/// in the WordPress client.
///
/// The value 'X-Local-Middleware' follows the convention of using 'X-' prefix
/// for custom headers, making it clear that this is a non-standard header
/// specific to this WordPress client implementation.
const String MIDDLEWARE_HEADER_KEY = 'X-Local-Middleware';
