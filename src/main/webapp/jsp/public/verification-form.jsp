<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>${pageTitle} - Hotel Management</title>
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
        
        .verification-container {
            background: white;
            border-radius: 15px;
            box-shadow: 0 10px 30px rgba(0,0,0,0.3);
            overflow: hidden;
            max-width: 600px;
            margin: 0 auto;
        }
        
        .verification-header {
            background: linear-gradient(135deg, #5a2b81, #8e44ad);
            color: white;
            padding: 30px;
            text-align: center;
        }
        
        .verification-body {
            padding: 40px;
        }
        
        .change-summary {
            background: #f8f9fa;
            border-left: 4px solid #5a2b81;
            padding: 20px;
            margin: 20px 0;
            border-radius: 5px;
        }
        
        .security-notice {
            background: #fff3cd;
            border: 1px solid #ffeaa7;
            color: #856404;
            padding: 15px;
            border-radius: 5px;
            margin: 20px 0;
        }
        
        .btn-approve {
            background: #28a745;
            border-color: #28a745;
            color: white;
            padding: 12px 30px;
            font-size: 16px;
            border-radius: 8px;
            margin-right: 10px;
        }
        
        .btn-reject {
            background: #dc3545;
            border-color: #dc3545;
            color: white;
            padding: 12px 30px;
            font-size: 16px;
            border-radius: 8px;
        }
        
        .user-info {
            display: flex;
            align-items: center;
            gap: 15px;
            margin-bottom: 20px;
        }
        
        .user-avatar {
            width: 60px;
            height: 60px;
            background: #5a2b81;
            color: white;
            border-radius: 50%;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 24px;
            font-weight: bold;
        }
    </style>
</head>
<body>
    <div class="container">
        <div class="verification-container">
            <div class="verification-header">
                <h2><i class="fas fa-shield-alt"></i> Account Change Verification</h2>
                <p class="mb-0">Secure verification required</p>
            </div>
            
            <div class="verification-body">
                <!-- User Information -->
                <div class="user-info">
                    <div class="user-avatar">
                        ${user.fullName.substring(0, 1).toUpperCase()}
                    </div>
                    <div>
                        <h5 class="mb-1">${user.fullName}</h5>
                        <p class="text-muted mb-0">${user.email}</p>
                    </div>
                </div>

                <!-- Change Summary -->
                <div class="change-summary">
                    <h6><i class="fas fa-edit"></i> Requested Change</h6>
                    <table class="table table-sm table-borderless mb-0">
                        <tr>
                            <th width="30%">Change Type:</th>
                            <td><strong>${change.changeTypeDisplayName}</strong></td>
                        </tr>
                        <c:if test="${change.changeType == 'EMAIL'}">
                            <tr>
                                <th>Current Email:</th>
                                <td>${change.originalEmail}</td>
                            </tr>
                            <tr>
                                <th>New Email:</th>
                                <td><strong>${change.newEmail}</strong></td>
                            </tr>
                        </c:if>
                        <c:if test="${change.changeType == 'PHONE'}">
                            <tr>
                                <th>Current Phone:</th>
                                <td>${not empty change.originalPhone ? change.originalPhone : 'Not set'}</td>
                            </tr>
                            <tr>
                                <th>New Phone:</th>
                                <td><strong>${not empty change.newPhone ? change.newPhone : 'Remove phone number'}</strong></td>
                            </tr>
                        </c:if>
                        <c:if test="${change.changeType == 'PASSWORD'}">
                            <tr>
                                <th>Current Password:</th>
                                <td>********</td>
                            </tr>
                            <tr>
                                <th>New Password:</th>
                                <td><strong>********</strong></td>
                            </tr>
                        </c:if>
                        <tr>
                            <th>Initiated By:</th>
                            <td>${change.initiatedByName} (Administrator)</td>
                        </tr>
                        <tr>
                            <th>Reason:</th>
                            <td>${change.changeReason}</td>
                        </tr>
                        <tr>
                            <th>Expires:</th>
                            <td>
                                <fmt:formatDate value="${change.tokenExpiry}" pattern="dd/MM/yyyy HH:mm"/>
                                <span class="badge badge-warning">${change.hoursUntilExpiry} hours left</span>
                            </td>
                        </tr>
                    </table>
                </div>

                <!-- Security Notice -->
                <div class="security-notice">
                    <i class="fas fa-exclamation-triangle"></i>
                    <strong>Security Notice:</strong> Only approve this change if you requested it or trust the administrator. 
                    If you did not request this change, please reject it and contact support immediately.
                </div>

                <c:choose>
                    <c:when test="${isReject}">
                        <!-- Reject Form -->
                        <h5 class="text-danger"><i class="fas fa-times-circle"></i> Reject Change Request</h5>
                        <p>Please provide a reason for rejecting this change request:</p>
                        
                        <form method="post" action="${pageContext.request.contextPath}/verify-change">
                            <input type="hidden" name="action" value="reject">
                            <input type="hidden" name="token" value="${change.verificationToken}">
                            
                            <div class="form-group">
                                <label>Rejection Reason:</label>
                                <textarea name="rejectionReason" class="form-control" rows="3" 
                                          placeholder="Please explain why you are rejecting this change..."></textarea>
                            </div>
                            
                            <div class="text-center">
                                <button type="submit" class="btn btn-reject">
                                    <i class="fas fa-times"></i> Reject Change
                                </button>
                                <a href="${pageContext.request.contextPath}/verify-change?token=${change.verificationToken}" 
                                   class="btn btn-secondary">
                                    <i class="fas fa-arrow-left"></i> Back to Review
                                </a>
                            </div>
                        </form>
                    </c:when>
                    <c:otherwise>
                        <!-- Approval/Rejection Options -->
                        <div class="text-center">
                            <p><strong>Do you approve this change to your account?</strong></p>
                            
                            <form method="post" action="${pageContext.request.contextPath}/verify-change" style="display: inline;">
                                <input type="hidden" name="action" value="approve">
                                <input type="hidden" name="token" value="${change.verificationToken}">
                                <button type="submit" class="btn btn-approve">
                                    <i class="fas fa-check"></i> Approve Change
                                </button>
                            </form>
                            
                            <a href="${pageContext.request.contextPath}/verify-change?token=${change.verificationToken}&action=reject" 
                               class="btn btn-reject">
                                <i class="fas fa-times"></i> Reject Change
                            </a>
                        </div>
                        
                        <div class="text-center mt-3">
                            <small class="text-muted">
                                By clicking "Approve Change", you confirm that you want this change applied to your account.
                            </small>
                        </div>
                    </c:otherwise>
                </c:choose>
            </div>
        </div>
    </div>

    <script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
    <script src="https://stackpath.bootstrapcdn.com/bootstrap/4.5.2/js/bootstrap.min.js"></script>
</body>
</html>