<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html>
<head>
    <title>Error - Room Inspector System</title>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <link rel="stylesheet" href="https://stackpath.bootstrapcdn.com/bootstrap/4.5.2/css/bootstrap.min.css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/5.15.3/css/all.min.css">
    <style>
        body { 
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; 
            background: #f8f9fa; 
            min-height: 100vh;
            display: flex;
            align-items: center;
            justify-content: center;
            margin: 0;
        }
        .error-container { 
            max-width: 600px; 
            width: 100%;
            background: #fff; 
            border-radius: 10px; 
            box-shadow: 0 0 20px rgba(0,0,0,0.1); 
            padding: 40px;
            margin: 20px;
        }
        .error-header {
            text-align: center;
            margin-bottom: 30px;
        }
        .error-icon {
            width: 80px;
            height: 80px;
            background: #dc3545;
            border-radius: 50%;
            display: flex;
            align-items: center;
            justify-content: center;
            margin: 0 auto 20px;
        }
        .error-icon i {
            font-size: 40px;
            color: white;
        }
        h2 { 
            color: #dc3545;
            margin-bottom: 10px;
            font-size: 28px;
            font-weight: 600;
        }
        .error-message { 
            background: #f8d7da;
            color: #721c24;
            padding: 15px 20px;
            border-radius: 5px;
            margin-bottom: 30px;
            border: 1px solid #f5c6cb;
        }
        .error-details {
            color: #6c757d;
            margin-bottom: 30px;
            line-height: 1.6;
        }
        .action-buttons {
            display: flex;
            gap: 15px;
            justify-content: center;
            flex-wrap: wrap;
        }
        .btn {
            padding: 10px 25px;
            border-radius: 5px;
            text-decoration: none;
            transition: all 0.3s;
            border: none;
            cursor: pointer;
        }
        .btn-primary {
            background: #007bff;
            color: white;
        }
        .btn-primary:hover {
            background: #0056b3;
            color: white;
            text-decoration: none;
        }
        .btn-secondary {
            background: #6c757d;
            color: white;
        }
        .btn-secondary:hover {
            background: #545b62;
            color: white;
            text-decoration: none;
        }
        .debug-info {
            margin-top: 30px;
            padding-top: 30px;
            border-top: 1px solid #dee2e6;
            font-size: 12px;
            color: #999;
            text-align: center;
        }
    </style>
</head>
<body>
    <div class="error-container">
        <div class="error-header">
            <div class="error-icon">
                <i class="fas fa-exclamation-triangle"></i>
            </div>
            <h2>Oops! Something went wrong</h2>
        </div>
        
        <div class="error-message">
            <c:choose>
                <c:when test="${not empty error}">
                    <i class="fas fa-info-circle"></i> ${error}
                </c:when>
                <c:otherwise>
                    <i class="fas fa-info-circle"></i> An unexpected error occurred. Please try again later.
                </c:otherwise>
            </c:choose>
        </div>
        
        <div class="error-details">
            <strong>What you can do:</strong>
            <ul>
                <li>Check if all required fields were filled correctly</li>
                <li>Verify that the reservation or room information is valid</li>
                <li>Try refreshing the page and attempting the action again</li>
                <li>If the problem persists, contact your administrator</li>
            </ul>
        </div>
        
        <div class="action-buttons">
           
            <a class="btn btn-secondary" href="javascript:history.back()">
                <i class="fas fa-arrow-left"></i> Go Back
            </a>
        </div>
        
        <c:if test="${pageContext.request.serverName == 'localhost'}">
            <div class="debug-info">
                <small>Error occurred at: <%= new java.util.Date() %></small>
            </div>
        </c:if>
    </div>
</body>
</html>