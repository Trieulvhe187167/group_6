<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Verification Result - Hotel Management</title>
    <link rel="stylesheet" href="https://stackpath.bootstrapcdn.com/bootstrap/4.5.2/css/bootstrap.min.css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/5.15.4/css/all.min.css">
    <style>
        body {
            background: linear-gradient(135deg, #5a2b81 0%, #8e44ad 100%);
            min-height: 100vh;
            display: flex;
            align-items: center;
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
        }
        
        .result-container {
            background: white;
            border-radius: 15px;
            box-shadow: 0 10px 30px rgba(0,0,0,0.3);
            overflow: hidden;
            max-width: 500px;
            margin: 0 auto;
            text-align: center;
        }
        
        .result-header {
            padding: 40px 30px 30px;
        }
        
        .result-icon {
            font-size: 80px;
            margin-bottom: 20px;
        }
        
        .success-icon {
            color: #28a745;
        }
        
        .error-icon {
            color: #dc3545;
        }
        
        .result-body {
            padding: 0 30px 40px;
        }
        
        .btn-home {
            background: #5a2b81;
            border-color: #5a2b81;
            color: white;
            padding: 12px 30px;
            border-radius: 8px;
            margin-top: 20px;
        }
    </style>
</head>
<body>
    <div class="container">
        <div class="result-container">
            <div class="result-header">
                <c:choose>
                    <c:when test="${not empty success}">
                        <div class="result-icon success-icon">
                            <i class="fas fa-check-circle"></i>
                        </div>
                        <h3 class="text-success">Success!</h3>
                    </c:when>
                    <c:otherwise>
                        <div class="result-icon error-icon">
                            <i class="fas fa-exclamation-circle"></i>
                        </div>
                        <h3 class="text-danger">Error</h3>
                    </c:otherwise>
                </c:choose>
            </div>
            
            <div class="result-body">
                <c:if test="${not empty success}">
                    <p class="lead">${success}</p>
                    <c:if test="${not empty message}">
                        <p class="text-muted">${message}</p>
                    </c:if>
                </c:if>
                
                <c:if test="${not empty error}">
                    <p class="lead">${error}</p>
                    <c:if test="${not empty message}">
                        <p class="text-muted">${message}</p>
                    </c:if>
                </c:if>
                
                <a href="${pageContext.request.contextPath}/" class="btn btn-home">
                    <i class="fas fa-home"></i> Return to Homepage
                </a>
            </div>
        </div>
    </div>
</body>
</html> 