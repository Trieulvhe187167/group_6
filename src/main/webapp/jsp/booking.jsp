    <%@ page contentType="text/html" pageEncoding="UTF-8" %>
<%@ page import="model.CartItem" %>
<%@ page import="java.util.List" %>
<%@ page import="java.text.DecimalFormat" %>
<%@ page import="dal.RoomTypeDAO" %>
<%@ page import="model.RoomType" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html>
    <head>
        <meta charset="UTF-8">
        <title>Booking Room</title>
        <link rel="icon" href="${pageContext.request.contextPath}/assets/images/favicon.ico" type="image/x-icon" />
        <link rel="shortcut icon" type="image/x-icon" href="${pageContext.request.contextPath}/assets/images/favicon.png" />

        <!-- All PLUGINS CSS -->
        <link rel="stylesheet" type="text/css" href="${pageContext.request.contextPath}/assets/css/assets.css">
        <link rel="stylesheet" type="text/css" href="${pageContext.request.contextPath}/assets/css/typography.css">
        <link rel="stylesheet" type="text/css" href="${pageContext.request.contextPath}/assets/css/shortcodes/shortcodes.css">
        <link rel="stylesheet" type="text/css" href="${pageContext.request.contextPath}/assets/css/style.css">
        <link class="skin" rel="stylesheet" type="text/css" href="${pageContext.request.contextPath}/assets/css/color/color-1.css">


        <!-- Loading-->
        <script src="${pageContext.request.contextPath}/assets/js/jquery.min.js"></script>
        <script>
            $(window).on('load', function () {
                $('#loading-icon-bx').fadeOut();
            });
        </script>
        <style>
            .payment-method-btn {
                border: 2px solid #dee2e6;
                background: #fff;
                padding: 1rem;
                border-radius: 10px;
                cursor: pointer;
                text-align: center;
                transition: all 0.3s ease;
            }
            .payment-method-btn:hover {
                border-color: #007bff;
                background: #f0f8ff;
            }
            .payment-method-btn.selected {
                border-color: #007bff;
                background: #007bff;
                color: #fff;
            }
        </style>
    </head>
    <body id="bg">
        <div class="page-wraper">
            <!-- Spinner -->
            <div id="loading-icon-bx"></div>


            <header class="header rs-nav header-transparent">
                <%@ include file="header.jsp" %>
            </header>


            <div class="page-banner ovbl-dark" style="background-image:url(${pageContext.request.contextPath}/assets/images/banner/banner2.jpg);">
                <div class="container">
                    <div class="page-banner-entry">
                        <h1 class="text-white">Booking Room</h1>
                    </div>            
                </div>
            </div>
            <div class="breadcrumb-row">
                <div class="container">
                    <ul class="list-inline">
                        <li><a href="${pageContext.request.contextPath}/index.jsp">Home</a></li>
                        <li><a href="${pageContext.request.contextPath}/jsp/cart.jsp">Cart</a></li>
                        <li>Booking Room</li>
                    </ul>
                </div>
            </div>

            <div class="container" style="margin-top:30px;">
                <h3>Booking Information</h3>
                <%
                    List<CartItem> cart = (List<CartItem>) session.getAttribute("cart");
            String paramRoomTypeId = request.getParameter("roomTypeId");
            boolean single = paramRoomTypeId != null && !paramRoomTypeId.isEmpty();
            DecimalFormat df = new DecimalFormat("#,##0");
            int capacity = 1;
            if(single){
                        String roomTypeName = request.getParameter("roomTypeName");
                        String priceStr = request.getParameter("price");
                        double price = 0;
                        try{
                            price = Double.parseDouble(priceStr);
                            RoomTypeDAO rtd = new RoomTypeDAO();
                            RoomType rtTmp = rtd.getRoomTypesById(Integer.parseInt(paramRoomTypeId));
                            if(rtTmp != null) capacity = rtTmp.getCapacity();
                        }catch(Exception ex){}
                %>
                <form id="bookingForm" action="${pageContext.request.contextPath}/BookingServlet" method="POST">
                    <input type="hidden" name="roomTypeId" value="<%= paramRoomTypeId %>">
                    <input type="hidden" name="basePrice" value="<%= price %>">
                    <table class="table table-bordered">
                        <thead>
                            <tr>
                                <th>Room Type</th>
                                <th>Check-in</th>
                                <th>Check-out</th>
                                <th>Guests (Adult/Children)</th>      
                            </tr>
                        </thead>
                        <tbody>
                            <tr>
                                <td><%= roomTypeName != null ? roomTypeName : "" %></td>
                                <td><input type="date" name="checkinDate" id="singleCheckIn" class="form-control" required value="<%= request.getParameter("checkIn") != null ? request.getParameter("checkIn") : "" %>"></td>
                                <td><input type="date" name="checkoutDate" id="singleCheckOut" class="form-control" required value="<%= request.getParameter("checkOut") != null ? request.getParameter("checkOut") : "" %>"></td>
                                <td>
                                    <input type="number" class="form-control d-inline-block" style="width:70px;" name="adults" id="adults" value="1" min="1" max="<%= capacity %>" onchange="updateChildLimit('', <%= capacity %>)">
                                    <input type="number" class="form-control d-inline-block ms-1" style="width:70px;" name="children" id="children" value="0" min="0" max="<%= capacity %>" onchange="updateChildLimit('', <%= capacity %>)">
                                </td>                              
                            </tr>
                        </tbody>
                    </table>
                    <p class="text-end" style="color: red"><strong>Total: <span id="singleSubtotal">0₫</span></strong></p>


                    <c:choose>
                        <c:when test="${not empty sessionScope.user}">
                            <h4>Booking By: ${sessionScope.user.fullName} </h4>
                            <input type="hidden" name="fullName" value="${sessionScope.user.fullName}">
                            <input type="hidden" name="email" value="${sessionScope.user.email}">
                            <input type="hidden" name="phone" value="${sessionScope.user.phone}">
                        </c:when>
                        <c:otherwise>
                            <h4>Customer Information</h4>
                            <div class="form-group">
                                <label>Full Name</label>
                                  <input type="text" name="fullName" class="form-control" maxlength="100" required />
                            </div>
                            <div class="form-group">
                                <label>Email</label>
                                <input type="email" name="email" class="form-control" maxlength="100" required />
                            </div>
                            <div class="form-group">
                                <label>Phone</label>
                                <input type="text" name="phone" class="form-control" pattern="0[0-9]{9}" maxlength="10" required />
                            </div>
                        </c:otherwise>
                    </c:choose>
                    <h4>Payment Method</h4>
                    <div class="row mb-3">
                        <div class="col-md-3">
                            <div class="payment-method-btn" onclick="selectPaymentMethod('CASH')">
                                <input type="radio" name="paymentMethod" value="CASH" hidden>
                                <i class="fas fa-money-bill-wave fa-2x mb-2"></i>
                                <div>Cash</div>
                            </div>
                        </div>
                        <div class="col-md-3">
                            <div class="payment-method-btn" onclick="selectPaymentMethod('BANK_TRANSFER')">
                                <input type="radio" name="paymentMethod" value="BANK_TRANSFER" hidden>
                                <i class="fas fa-qrcode fa-2x mb-2"></i>
                                <div>Bank Transfer</div>
                            </div>
                        </div>
                    </div>
                    <div class="d-flex justify-content-between my-5 px-5">

                        <a href="javascript:history.back()" class="btn btn-outline-secondary px-4">
                            <i class="fas fa-arrow-left"></i> Back
                        </a>

                        <button type="submit" class="btn btn-primary px-4">Confirm Booking</button>
                    </div>
                </form>
                <%
                    } else if(cart != null && !cart.isEmpty()) {
                        double grandTotal = 0;
                %>
                <table class="table table-bordered">
                    <thead>
                        <tr>
                            <th>Room Type</th>
                            <th>Check-in</th>
                            <th>Check-out</th>
                            <th>Quantity</th>
                            <th>Guests (Adult/Children)</th>
                            <th>Subtotal</th>
                        </tr>
                    </thead>
                    <tbody>
                        <%
                            int index = 0;
                            for(CartItem item : cart){
                                java.time.LocalDate checkInDate = java.time.LocalDate.parse(item.getCheckIn());
                                java.time.LocalDate checkOutDate = java.time.LocalDate.parse(item.getCheckOut());
                                long nights = java.time.temporal.ChronoUnit.DAYS.between(checkInDate, checkOutDate);
                                double sub = item.getPrice().doubleValue() * item.getQuantity() * nights;
                                grandTotal += sub;
                        %>
                        <tr>
                            <td><%= item.getRoomTypeName() %></td>
                            <td><%= item.getCheckIn() %></td>
                            <td><%= item.getCheckOut() %></td>
                            <td><%= item.getQuantity() %></td>
                            <td>
                                <input type="number" class="form-control d-inline-block" style="width:70px;" name="adults<%=index%>" id="adults<%=index%>" value="<%= item.getAdults() %>" min="1" max="<%= item.getCapacity() %>" onchange="updateChildLimit(<%=index%>, <%= item.getCapacity() %>)">
                                <input type="number" class="form-control d-inline-block ms-1" style="width:70px;" name="children<%=index%>" id="children<%=index%>" value="<%= item.getChildren() %>" min="0" max="<%= item.getCapacity() %>" onchange="updateChildLimit(<%=index%>, <%= item.getCapacity() %>)">
                            </td>
                            <td><%= df.format(sub) %>₫</td>
                        </tr>
                        <%
                                index++;
                            }
                        %>
                    </tbody>
                </table>
                <p class="text-end" style="color: red"><strong>Total: <%= df.format(grandTotal) %>₫</strong></p>
                <form id="bookingForm" action="${pageContext.request.contextPath}/BookingServlet" method="POST">

                    <c:choose>
                        <c:when test="${not empty sessionScope.user}">
                            <h4>Booking By: ${sessionScope.user.fullName} </h4>
                            <input type="hidden" name="fullName" value="${sessionScope.user.fullName}">
                            <input type="hidden" name="email" value="${sessionScope.user.email}">
                            <input type="hidden" name="phone" value="${sessionScope.user.phone}">
                        </c:when>
                        <c:otherwise>
                            <h4>Customer Information</h4>
                            <div class="form-group">
                                <label>Full Name</label>
                                <input type="text" name="fullName" class="form-control" maxlength="100" required />
                            </div>
                            <div class="form-group">
                                <label>Email</label>
                                <input type="email" name="email" class="form-control" maxlength="100" required />
                            </div>
                            <div class="form-group">
                                <label>Phone</label>
                                <input type="text" name="phone" class="form-control" pattern="0[0-9]{9}" maxlength="10" required />
                            </div>
                        </c:otherwise>
                    </c:choose>

                    <h4>Payment Method</h4>
                    <div class="row mb-3">
                        <div class="col-md-3">
                            <div class="payment-method-btn" onclick="selectPaymentMethod('CASH')">
                                <input type="radio" name="paymentMethod" value="CASH" hidden>
                                <i class="fas fa-money-bill-wave fa-2x mb-2"></i>
                                <div>Cash</div>
                            </div>
                        </div>
                        <div class="col-md-3">
                            <div class="payment-method-btn" onclick="selectPaymentMethod('BANK_TRANSFER')">
                                <input type="radio" name="paymentMethod" value="BANK_TRANSFER" hidden>
                                <i class="fas fa-qrcode fa-2x mb-2"></i>
                                <div>Bank Transfer</div>
                            </div>
                        </div>
<!--                        <div class="col-md-3">
                            <div class="payment-method-btn" onclick="selectPaymentMethod('CREDIT_CARD')">
                                <input type="radio" name="paymentMethod" value="CREDIT_CARD" hidden>
                                <i class="fas fa-credit-card fa-2x mb-2"></i>
                                <div>Credit Card</div>
                            </div>
                        </div>-->
                        <!--                <div class="col-md-3">
                                            <div class="payment-method-btn" onclick="selectPaymentMethod('VNPay')">
                                                <input type="radio" name="paymentMethod" value="VNPay" hidden>
                                                <i class="fas fa-qrcode fa-2x mb-2"></i>
                                                <div>VNPay</div>
                                            </div>
                                        </div>
                                        <div class="col-md-3">
                                            <div class="payment-method-btn" onclick="selectPaymentMethod('MoMo')">
                                                <input type="radio" name="paymentMethod" value="MoMo" hidden>
                                                <i class="fas fa-mobile-alt fa-2x mb-2"></i>
                                                <div>MoMo</div>
                                            </div>
                                        </div>-->
                    </div>

                    <div class="d-flex justify-content-between my-5 px-5">

                        <a href="${pageContext.request.contextPath}/CartServlet"
                           class="btn btn-secondary px-4">
                            Back to Cart
                        </a>

                        <a href="javascript:history.back()" class="btn btn-outline-secondary px-4">
                            <i class="fas fa-arrow-left"></i> Back
                        </a>

                        <button type="submit" class="btn btn-primary px-4">Confirm Booking</button>
                    </div>
                </form>
                <%
                    } else {
                %>
                <p>Your cart is empty.</p>
                <%
                    }
                %>
            </div>
            <jsp:include page="footer.jsp" />

            <!-- OTP Modal -->
            <div class="modal fade" id="otpModal" tabindex="-1" role="dialog" aria-hidden="true">
                <div class="modal-dialog" role="document">
                    <div class="modal-content">
                        <div class="modal-header">
                            <h5 class="modal-title">Email Verification</h5>
                            <button type="button" class="close" data-dismiss="modal" aria-label="Close">
                                <span aria-hidden="true">&times;</span>
                            </button>
                        </div>
                        <div class="modal-body">
                            <p>A verification code has been sent to <span id="maskedEmail"></span>.</p>
                            <input type="text" id="otpInput" class="form-control" placeholder="Enter OTP" maxlength="6">
                            <small id="otpMessage" class="text-danger"></small>
                        </div>
                        <div class="modal-footer">
                            <button type="button" class="btn btn-secondary" id="resendOTP">Resend</button>
                            <button type="button" class="btn btn-primary" id="submitOTP">Verify</button>
                        </div>
                    </div>
                </div>
            </div>

            <!-- Scripts -->
            <script src="${pageContext.request.contextPath}/assets/js/jquery.min.js"></script>
            <script src="${pageContext.request.contextPath}/assets/vendors/bootstrap/js/popper.min.js"></script>
            <script src="${pageContext.request.contextPath}/assets/vendors/bootstrap/js/bootstrap.min.js"></script>
            <script>
                                var pendingData = null;

                                $('#bookingForm').on('submit', function (e) {
                                    e.preventDefault();
                                    pendingData = $(this).serialize();
                                    $.post($(this).attr('action'), pendingData, function (res) {
                                        if (res.requireOTP) {
                                            $('#maskedEmail').text(res.email);
                                            $('#otpMessage').text('');
                                            $('#otpModal').modal('show');
                                        } else if (res.success) {
                                            var method = $('input[name="paymentMethod"]:checked').val() || 'CASH';
                                            var resIds = res.reservationIds ? res.reservationIds : res.reservationId;
                                            var payIds = res.paymentIds ? res.paymentIds : res.paymentId;
                                            window.location.href = '${pageContext.request.contextPath}/PaymentGateway?reservationIds=' + resIds + '&paymentIds=' + payIds + '&method=' + method;
                                        } else if (res.error) {
                                            alert(res.error);
                                        }
                                    }, 'json').fail(function () {
                                        alert('Error processing booking');
                                    });
                                });

                                $('#submitOTP').on('click', function () {
                                    var otp = $('#otpInput').val().trim();
                                    if (!otp) {
                                        $('#otpMessage').text('Please enter OTP');
                                        return;
                                    }
                                    $.post('${pageContext.request.contextPath}/ValidateOTP', {otp: otp}, function (res) {
                                        if (res.success) {
                                            $('#otpModal').modal('hide');
                                            $.post('${pageContext.request.contextPath}/BookingServlet', pendingData, function (r) {
                                                if (r.success) {
                                                    var method = $('input[name="paymentMethod"]:checked').val() || 'CASH';
                                                    var resIds = r.reservationIds ? r.reservationIds : r.reservationId;
                                                    var payIds = r.paymentIds ? r.paymentIds : r.paymentId;
                                                    window.location.href = '${pageContext.request.contextPath}/PaymentGateway?reservationIds=' + resIds + '&paymentIds=' + payIds + '&method=' + method;
                                                } else if (r.error) {
                                                    alert(r.error);
                                                }
                                            }, 'json');
                                        } else {
                                            $('#otpMessage').text(res.message || 'Invalid OTP');
                                        }
                                    }, 'json').fail(function () {
                                        $('#otpMessage').text('Error validating OTP');
                                    });
                                });

                                $('#resendOTP').on('click', function () {
                                    $.post('${pageContext.request.contextPath}/ResendOTP', function (res) {
                                        if (res.success) {
                                            $('#otpMessage').text('OTP resent');
                                        } else {
                                            $('#otpMessage').text(res.message || 'Failed to resend OTP');
                                        }
                                    }, 'json');
                                });

                                function selectPaymentMethod(method) {
                                    $('.payment-method-btn').removeClass('selected');
                                    $('input[name="paymentMethod"][value="' + method + '"]').prop('checked', true)
                                            .parent('.payment-method-btn').addClass('selected');
                                }

                                function updateChildLimit(idx, capacity) {
                                    var adultsInput = document.getElementById('adults' + idx);
                                    var childrenInput = document.getElementById('children' + idx);
                                    if (!adultsInput || !childrenInput)
                                        return;
                                    var adults = parseInt(adultsInput.value) || 1;
                                    if (adults < 1)
                                        adults = 1;
                                    if (adults > capacity)
                                        adults = capacity;
                                    adultsInput.value = adults;
                                    var childLimit = (adults >= capacity) ? 1 : (capacity - adults) * 2;
                                    childrenInput.max = childLimit;
                                    var children = parseInt(childrenInput.value) || 0;
                                    if (children < 0)
                                        children = 0;
                                    if (children > childLimit)
                                        children = childLimit;
                                    childrenInput.value = children;
                                }

                                function setMinDates() {
                                    var inEl = document.getElementById('singleCheckIn');
                                    var outEl = document.getElementById('singleCheckOut');
                                    if (!inEl || !outEl)
                                        return;
                                    var today = new Date();
                                    var todayStr = today.toISOString().split('T')[0];
                                    if (!inEl.value || inEl.value < todayStr) {
                                        inEl.value = todayStr;
                                    }
                                    inEl.min = todayStr;
                                    updateCheckoutMinSingle();
                                }

                                function updateCheckoutMinSingle() {
                                    var inEl = document.getElementById('singleCheckIn');
                                    var outEl = document.getElementById('singleCheckOut');
                                    if (!inEl || !outEl)
                                        return;
                                    var d = new Date(inEl.value);
                                    d.setDate(d.getDate() + 1);
                                    var minStr = d.toISOString().split('T')[0];
                                    outEl.min = minStr;
                                    if (!outEl.value || outEl.value < minStr) {
                                        outEl.value = minStr;
                                    }
                                    updateSingleSubtotal();
                                }

                                function updateSingleSubtotal() {
                                    var inEl = document.getElementById('singleCheckIn');
                                    var outEl = document.getElementById('singleCheckOut');
                                    var priceInput = document.querySelector('input[name="basePrice"]');
                                    if (!inEl || !outEl || !priceInput)
                                        return;
                                    var price = parseFloat(priceInput.value) || 0;
                                    var inDate = new Date(inEl.value);
                                    var outDate = new Date(outEl.value);
                                    var nights = Math.ceil((outDate - inDate) / (1000 * 60 * 60 * 24));
                                    if (nights < 1)
                                        nights = 1;
                                    var subtotal = price * nights;
                                    document.getElementById('singleSubtotal').textContent =
                                            new Intl.NumberFormat('vi-VN').format(subtotal) + '₫';
                                }

                                document.addEventListener('DOMContentLoaded', function () {
                                    setMinDates();
                                    var inEl = document.getElementById('singleCheckIn');
                                    var outEl = document.getElementById('singleCheckOut');
                                    if (inEl)
                                        inEl.addEventListener('change', updateCheckoutMinSingle);
                                    if (outEl)
                                        outEl.addEventListener('change', updateSingleSubtotal);
                <% if(single){ %>
                                    var cap = <%= capacity %>;
                                    updateChildLimit('', cap);
                                    var adultsInput = document.getElementById('adults');
                                    var childrenInput = document.getElementById('children');
                                    if (adultsInput)
                                        adultsInput.addEventListener('change', function () {
                                            updateChildLimit('', cap);
                                        });
                                    if (childrenInput)
                                        childrenInput.addEventListener('change', function () {
                                            updateChildLimit('', cap);
                                        });
                <% } %>
                                    updateSingleSubtotal();
                                });
            </script>

            <script>
                (function ($) {
                    $(window).on('scroll', function () {
                        if ($(window).scrollTop() > 50) {
                            $('.sticky-header.navbar-expand-lg').addClass('is-fixed');
                        } else {
                            $('.sticky-header.navbar-expand-lg').removeClass('is-fixed');
                        }
                    });
                })(jQuery);
            </script>

    </body>
</html>