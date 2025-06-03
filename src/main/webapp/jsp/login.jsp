<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="model.User" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="utf-8">
    <base href="${pageContext.request.contextPath}/" />
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>LUXURY HƠTEL</title>

    <!-- Favicon -->
    <link rel="icon" href="assets/images/favicon.ico" type="image/x-icon" />
    <link rel="shortcut icon" type="image/x-icon" href="assets/images/favicon.png" />

    <!-- All CSS -->
    <link rel="stylesheet" type="text/css" href="assets/css/assets.css">
    <link rel="stylesheet" type="text/css" href="assets/css/typography.css">
    <link rel="stylesheet" type="text/css" href="assets/css/shortcodes/shortcodes.css">
    <link rel="stylesheet" type="text/css" href="assets/css/style.css">
    <link class="skin" rel="stylesheet" type="text/css" href="assets/css/color/color-1.css">
</head>
<body id="bg">
<div class="page-wraper">
    <div id="loading-icon-bx"></div>
    <div class="account-form">
        <div class="account-head" style="background-image:url(assets/images/background/bg2.jpg);">
            <a href="index.jsp"><img src="assets/images/logo-white-2.png" alt=""></a>
        </div>
        <div class="account-form-inner">
            <div class="account-container">
                <div class="heading-bx left">
                    <h2 class="title-head">Login to your <span>Account</span></h2>
                    <p>Don't have an account? <a href="jsp/Register.jsp">Create one here</a></p>
                </div>
                <%
                    User user = (User) session.getAttribute("user");
                    if (user != null) {
                %>
                    <div class="alert alert-success" style="color: green; font-weight: bold; margin-bottom: 15px;">
                        Đăng nhập thành công! Xin chào <%= user.getFullName() %>!
                    </div>
                <%
                    }
                %>

                <c:if test="${not empty errorMsg}">
                    <div class="alert alert-danger" style="color: red; font-weight: bold; margin-bottom: 15px;">
                        ${errorMsg}
                    </div>
                </c:if>

                <form class="contact-bx" method="post" action="LoginServlet">
                    <div class="row placeani">
                        <div class="col-lg-12">
                            <div class="form-group">
                                <div class="input-group">
                                    
                                    <input name="username" type="text" required class="form-control" placeholder="Enter your username or email">
                                </div>
                            </div>
                        </div>
                        <div class="col-lg-12">
                            <div class="form-group">
                                <div class="input-group">
                                    
                                    <input name="password" type="password" required class="form-control" placeholder="Enter your Password">
                                </div>
                            </div>
                        </div>
                        <div class="col-lg-12">
                            <div class="form-group form-forget">
                                <div class="custom-control custom-checkbox">
                                    <input type="checkbox" class="custom-control-input" id="rememberMe">
                                    <label class="custom-control-label" for="rememberMe">Remember me</label>
                                </div>
                                <a href="jsp/forgot-password.jsp" class="ml-auto">Forgot Password?</a>
                            </div>
                        </div>
                        <div class="col-lg-12 m-b30">
                            <button name="submit" type="submit" value="Submit" class="btn button-md">Login</button>
                        </div>
                    </div>
                </form>
            </div>
        </div>
    </div>
</div>

<!-- Scripts -->
<script src="assets/js/jquery.min.js"></script>
<script src="assets/vendors/bootstrap/js/popper.min.js"></script>
<script src="assets/vendors/bootstrap/js/bootstrap.min.js"></script>
<script src="assets/vendors/bootstrap-select/bootstrap-select.min.js"></script>
<script src="assets/vendors/bootstrap-touchspin/jquery.bootstrap-touchspin.js"></script>
<script src="assets/vendors/magnific-popup/magnific-popup.js"></script>
<script src="assets/vendors/counter/waypoints-min.js"></script>
<script src="assets/vendors/counter/counterup.min.js"></script>
<script src="assets/vendors/imagesloaded/imagesloaded.js"></script>
<script src="assets/vendors/masonry/masonry.js"></script>
<script src="assets/vendors/masonry/filter.js"></script>
<script src="assets/vendors/owl-carousel/owl.carousel.js"></script>
<script src="assets/js/functions.js"></script>
<script src="assets/js/contact.js"></script>
<script src='assets/vendors/switcher/switcher.js'></script>

</body>
</html>
