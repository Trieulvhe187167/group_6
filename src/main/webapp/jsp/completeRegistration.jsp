<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@ page import="model.User" %>
<!DOCTYPE html>
<html>
    <head>
        <meta charset="utf-8">
        <meta http-equiv="X-UA-Compatible" content="IE=edge">
        <meta name="viewport" content="width=device-width, initial-scale=1">
        
        <title>Complete Registration - Luxury Hotel</title>
        
        <!-- FAVICONS ICON -->
        <link rel="icon" href="${pageContext.request.contextPath}/assets/images/favicon.ico" type="image/x-icon" />
        <link rel="shortcut icon" type="image/x-icon" href="${pageContext.request.contextPath}/assets/images/favicon.png" />
        
        <!-- All PLUGINS CSS -->
        <link rel="stylesheet" type="text/css" href="${pageContext.request.contextPath}/assets/css/assets.css">
        <link rel="stylesheet" type="text/css" href="${pageContext.request.contextPath}/assets/css/typography.css">
        <link rel="stylesheet" type="text/css" href="${pageContext.request.contextPath}/assets/css/shortcodes/shortcodes.css">
        <link rel="stylesheet" type="text/css" href="${pageContext.request.contextPath}/assets/css/style.css">
        <link class="skin" rel="stylesheet" type="text/css" href="${pageContext.request.contextPath}/assets/css/color/color-1.css">
        
        <style>
            .registration-box {
                max-width: 500px;
                margin: 50px auto;
                padding: 40px;
                background: white;
                border-radius: 10px;
                box-shadow: 0 0 20px rgba(0,0,0,0.1);
            }
            
            .benefits-list {
                background: #f8f9fa;
                padding: 20px;
                border-radius: 8px;
                margin: 20px 0;
            }
            
            .benefits-list li {
                list-style: none;
                padding: 8px 0;
                padding-left: 25px;
                position: relative;
            }
            
            .benefits-list li:before {
                content: "✓";
                position: absolute;
                left: 0;
                color: #4CAF50;
                font-weight: bold;
            }
            
            .password-strength {
                margin-top: 5px;
                font-size: 12px;
            }
            
            .password-strength.weak { color: #dc3545; }
            .password-strength.medium { color: #ffc107; }
            .password-strength.strong { color: #28a745; }
        </style>
    </head>
    <body id="bg">
        <div class="page-wraper">
            <div id="loading-icon-bx"></div>
            
            <!-- Header -->
            <jsp:include page="header.jsp" />
            
            <%
                User user = (User) request.getAttribute("user");
                String token = (String) request.getAttribute("token");
                String error = (String) request.getAttribute("error");
            %>
            
            <!-- Content -->
            <div class="page-content bg-white">
                <!-- Page Banner -->
                <div class="page-banner ovbl-dark" style="background-image:url(assets/images/banner/banner2.jpg);">
                    <div class="container">
                        <div class="page-banner-entry">
                            <h1 class="text-white">Complete Your Registration</h1>
                        </div>
                    </div>
                </div>
                
                <!-- Registration Form -->
                <div class="section-area section-sp1">
                    <div class="container">
                        <div class="registration-box">
                            <h3 class="text-center mb-4">Welcome <%= user.getFullName() %>!</h3>
                            <p class="text-center text-muted mb-4">
                                Complete your registration to unlock exclusive member benefits
                            </p>
                            
                            <div class="benefits-list">
                                <h5>Member Benefits:</h5>
                                <ul>
                                    <li>Earn loyalty points with every stay</li>
                                    <li>Access to exclusive member rates (up to 20% off)</li>
                                    <li>Priority check-in and check-out</li>
                                    <li>Special birthday offers and seasonal promotions</li>
                                    <li>Free room upgrades (subject to availability)</li>
                                    <li>Complimentary late check-out</li>
                                </ul>
                            </div>
                            
                            <% if (error != null) { %>
                            <div class="alert alert-danger">
                                <%= error %>
                            </div>
                            <% } %>
                            
                            <form method="post" action="complete-registration" onsubmit="return validateForm()">
                                <input type="hidden" name="token" value="<%= token %>">
                                
                                <div class="form-group">
                                    <label>Email</label>
                                    <input type="email" class="form-control" value="<%= user.getEmail() %>" readonly>
                                </div>
                                
                                <div class="form-group">
                                    <label>Create Password</label>
                                    <input type="password" name="password" id="password" class="form-control" 
                                           required minlength="6" onkeyup="checkPasswordStrength()">
                                    <div id="passwordStrength" class="password-strength"></div>
                                </div>
                                
                                <div class="form-group">
                                    <label>Confirm Password</label>
                                    <input type="password" name="confirmPassword" id="confirmPassword" 
                                           class="form-control" required minlength="6">
                                </div>
                                
                                <div class="form-group">
                                    <div class="form-check">
                                        <input type="checkbox" class="form-check-input" id="newsletter" checked>
                                        <label class="form-check-label" for="newsletter">
                                            I want to receive exclusive offers and promotions
                                        </label>
                                    </div>
                                </div>
                                
                                <button type="submit" class="btn btn-primary btn-block">
                                    Complete Registration
                                </button>
                                
                                <p class="text-center mt-3">
                                    <a href="login.jsp">Skip for now</a>
                                </p>
                            </form>
                        </div>
                    </div>
                </div>
            </div>
            
            <!-- Footer -->
            <jsp:include page="footer.jsp" />
            
            <button class="back-to-top fa fa-chevron-up"></button>
        </div>
        
        <!-- External JavaScripts -->
        <script src="${pageContext.request.contextPath}/assets/js/jquery.min.js"></script>
        <script src="${pageContext.request.contextPath}/assets/vendors/bootstrap/js/popper.min.js"></script>
        <script src="${pageContext.request.contextPath}/assets/vendors/bootstrap/js/bootstrap.min.js"></script>
        <script src="${pageContext.request.contextPath}/assets/js/functions.js"></script>
        
        <script>
            function checkPasswordStrength() {
                const password = document.getElementById('password').value;
                const strengthDiv = document.getElementById('passwordStrength');
                
                let strength = 0;
                if (password.length >= 8) strength++;
                if (password.match(/[a-z]+/)) strength++;
                if (password.match(/[A-Z]+/)) strength++;
                if (password.match(/[0-9]+/)) strength++;
                if (password.match(/[$@#&!]+/)) strength++;
                
                if (password.length < 6) {
                    strengthDiv.className = 'password-strength weak';
                    strengthDiv.textContent = 'Password too short';
                } else if (strength < 3) {
                    strengthDiv.className = 'password-strength weak';
                    strengthDiv.textContent = 'Weak password';
                } else if (strength === 3) {
                    strengthDiv.className = 'password-strength medium';
                    strengthDiv.textContent = 'Medium strength';
                } else {
                    strengthDiv.className = 'password-strength strong';
                    strengthDiv.textContent = 'Strong password';
                }
            }
            
            function validateForm() {
                const password = document.getElementById('password').value;
                const confirmPassword = document.getElementById('confirmPassword').value;
                
                if (password !== confirmPassword) {
                    alert('Passwords do not match');
                    return false;
                }
                
                return true;
            }
        </script>
    </body>
</html>