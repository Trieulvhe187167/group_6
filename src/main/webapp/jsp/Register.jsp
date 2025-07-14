<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="utf-8">
    <title>LUXURY HOTEL - Register</title>
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <link rel="icon" href="../assets/images/favicon.ico" type="image/x-icon" />
    <link rel="shortcut icon" type="image/x-icon" href="../assets/images/favicon.png" />
    <link rel="stylesheet" type="text/css" href="../assets/css/assets.css">
    <link rel="stylesheet" type="text/css" href="../assets/css/typography.css">
    <link rel="stylesheet" type="text/css" href="../assets/css/shortcodes/shortcodes.css">
    <link rel="stylesheet" type="text/css" href="../assets/css/style.css">
    <link class="skin" rel="stylesheet" type="text/css" href="../assets/css/color/color-1.css">

    <style>
        .modal {
            position: fixed;
            top: 0; left: 0; right: 0; bottom: 0;
            background-color: rgba(0,0,0,0.6);
            z-index: 1000;
            display: flex;
            align-items: center;
            justify-content: center;
        }
        .modal-content {
            background: white;
            padding: 25px;
            width: 400px;
            border-radius: 8px;
            text-align: center;
        }
        .modal-content input {
            margin-bottom: 12px;
        }
        .otp-buttons form {
            margin: 5px 0;
        }
        .otp-buttons button {
            width: 100%;
            padding: 10px;
            font-weight: bold;
            background-color: #ffc107;
            border: none;
            color: black;
            border-radius: 5px;
        }
        .otp-buttons button:hover {
            background-color: #e0a800;
        }
        .modal-content .message {
            margin-top: 10px;
            font-weight: bold;
        }
    </style>
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
                    <h2 class="title-head">Sign Up <span>Now</span></h2>
                    <p>Already have an account? <a href="login.jsp">Click here</a></p>
                </div>

                <c:if test="${not empty errorMsg}">
                    <div style="color:red; font-weight:bold; margin-bottom:10px;">
                        ${errorMsg}
                    </div>
                </c:if>

                <form class="contact-bx" action="../RegisterServlet" method="post">
                    <div class="row placeani">
                        <div class="col-lg-12">
                            <div class="form-group">
                                <label for="fullNameInput">Full Name</label>
                                <div class="input-group">
                                    <input name="name" type="text" required class="form-control"
                                           placeholder="Full Name" maxlength="25"
                                           value="${fullName != null ? fullName : ''}">
                                </div>
                            </div>
                        </div>

                        <div class="col-lg-12">
                            <div class="form-group">
                                <label for="userNameInput">User Name</label>
                                <div class="input-group">
                                    <input name="username" type="text" required class="form-control"
                                           placeholder="Username" maxlength="25"
                                           value="${username != null ? username : ''}">
                                </div>
                            </div>
                        </div>

                        <div class="col-lg-12">
                            <div class="form-group">
                                <label for="EmailInput">Email</label>
                                <div class="input-group">
                                    <input name="email" type="email" required class="form-control"
                                           placeholder="Email" maxlength="50"
                                           value="${email != null ? email : ''}">
                                </div>
                            </div>
                        </div>

                        <div class="col-lg-12">
                            <div class="form-group">
                                <label for="PasswordInput">Password</label>
                                <div class="input-group">
                                    <input name="password" type="password" required class="form-control"
                                           placeholder="Password">
                                </div>
                            </div>
                        </div>

                        <div class="col-lg-12">
                            <div class="form-group">
                                <label for="PhoneInput">Phone number</label>
                                <div class="input-group">
                                    <input name="phone" type="text" required class="form-control"
                                           placeholder="Phone number"
                                           value="${phone != null ? phone : ''}">
                                </div>
                            </div>
                        </div>

                        <div class="col-lg-12 m-b30">
                            <button type="submit" class="btn button-md">Sign Up</button>
                        </div>
                    </div>
                </form>
            </div>
        </div>
    </div>
</div>

<!-- OTP Modal -->
<c:if test="${sessionScope.otpStep}">
    <div id="otpModal" class="modal">
        <div class="modal-content">
            <h4>Email Verification</h4>
            <p>A 6-digit verification code was sent to your email.</p>

            <!-- Verify Form -->
            <form action="../RegisterServlet" method="post">
                <input type="hidden" name="action" value="verify"/>
                <input name="code" type="text" required class="form-control"
                       placeholder="Enter OTP" maxlength="6" pattern="\d{6}"
                       title="OTP must be exactly 6 digits" />
                <div class="otp-buttons">
                    <button type="submit">Verify & Finish</button>
                </div>
            </form>

            <!-- Resend and Restart -->
            <div class="otp-buttons">
                <form action="../RegisterServlet" method="post">
                    <input type="hidden" name="action" value="resend"/>
                    <button type="submit">Resend Code</button>
                </form>

                <form action="../RegisterServlet" method="post">
                    <input type="hidden" name="action" value="restart"/>
                    <button type="submit">Start Over</button>
                </form>
            </div>

            <!-- Message -->
            <c:if test="${not empty error}">
                <p class="message" style="color:red;">${error}</p>
            </c:if>
            <c:if test="${not empty info}">
                <p class="message" style="color:green;">${info}</p>
            </c:if>
        </div>
    </div>
</c:if>

<!-- JS -->
<script src="../assets/js/jquery.min.js"></script>
<script>
document.addEventListener("DOMContentLoaded", function () {
    const otpInput = document.querySelector('input[name="code"]');
    if (otpInput) {
        otpInput.addEventListener("input", function (e) {
            this.value = this.value.replace(/\D/g, "").slice(0, 6); // Chỉ nhập số
        });
    }
});
</script>
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
