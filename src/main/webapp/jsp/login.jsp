<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="utf-8">
    <title>LUXURY HOTEL - Login</title>
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <link rel="icon" href="../assets/images/favicon.ico" type="image/x-icon" />
    <link rel="shortcut icon" type="image/x-icon" href="../assets/images/favicon.png" />
    <link rel="stylesheet" type="text/css" href="../assets/css/assets.css">
    <link rel="stylesheet" type="text/css" href="../assets/css/typography.css">
    <link rel="stylesheet" type="text/css" href="../assets/css/shortcodes/shortcodes.css">
    <link rel="stylesheet" type="text/css" href="../assets/css/style.css">
    <link class="skin" rel="stylesheet" type="text/css" href="../assets/css/color/color-1.css">
</head>

<body id="bg">
<div class="page-wraper">
    <div id="loading-icon-bx"></div>
    <div class="account-form">
        <div class="account-head" style="background-image:url(../assets/images/background/bg2.jpg);">
            <a href="../index.jsp"><img src="../assets/images/logo-white-2.png" alt=""></a>
        </div>
        <div class="account-form-inner">
            <div class="account-container">
                <div class="heading-bx left">
                    <h2 class="title-head">Login to your <span>Account</span></h2>
                    <p>Don't have an account? <a href="Register.jsp">Register here</a></p>
                </div>

                <!-- Registration success message -->
                <c:if test="${param.success == '1'}">
                    <div class="alert alert-success" style="color: green; font-weight: bold; margin-bottom: 15px;">
                        Registration successful! Please log in.
                    </div>
                </c:if>

                <!-- Login error message -->
                <c:if test="${not empty errorMsg}">
                    <div class="alert alert-danger" style="color: red; font-weight: bold; margin-bottom: 15px;">
                        ${errorMsg}
                    </div>
                </c:if>

                <form class="contact-bx" action="../LoginServlet" method="post">
                    <div class="row placeani">
                        <div class="col-lg-12">
                            <div class="form-group">
                                <div class="input-group">
                                    <input name="username" type="text" required class="form-control" placeholder="Username">
                                </div>
                            </div>
                        </div>
                        <div class="col-lg-12">
                            <div class="form-group">
                                <div class="input-group">
                                    <input name="password" type="password" required class="form-control" placeholder="Password">
                                </div>
                            </div>
                        </div>
                        <div class="col-lg-12 m-b30">
                            <button type="submit" class="btn button-md">Login</button>
                        </div>
                    </div>
                </form>
                        <p>Forget password? <a href="forgotPassword.jsp">click here</a></p>
            </div>
        </div>
    </div>
</div>

<!-- JS -->
<script src="../assets/js/jquery.min.js"></script>
<script src="../assets/vendors/bootstrap/js/popper.min.js"></script>
<script src="../assets/vendors/bootstrap/js/bootstrap.min.js"></script>
<script src="../assets/vendors/bootstrap-select/bootstrap-select.min.js"></script>
<script src="../assets/vendors/bootstrap-touchspin/jquery.bootstrap-touchspin.js"></script>
<script src="../assets/vendors/magnific-popup/magnific-popup.js"></script>
<script src="../assets/vendors/counter/waypoints-min.js"></script>
<script src="../assets/vendors/counter/counterup.min.js"></script>
<script src="../assets/vendors/imagesloaded/imagesloaded.js"></script>
<script src="../assets/vendors/masonry/masonry.js"></script>
<script src="../assets/vendors/masonry/filter.js"></script>
<script src="../assets/vendors/owl-carousel/owl.carousel.js"></script>
<script src="../assets/js/functions.js"></script>
<script src="../assets/js/contact.js"></script>

</body>
</html>

