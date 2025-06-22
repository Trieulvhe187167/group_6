<%-- 
    Document   : bookingConfirmation
    Created on : ${date}
    Author     : ${user}
--%>

<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@ page import="model.*" %>
<%@ page import="java.util.List" %>
<%@ page import="java.text.DecimalFormat" %>
<%@ page import="java.text.SimpleDateFormat" %>
<!DOCTYPE html>
<html>
    <head>
        <meta charset="utf-8">
        <meta http-equiv="X-UA-Compatible" content="IE=edge">
        <meta name="keywords" content="" />
        <meta name="author" content="" />
        <meta name="robots" content="" />

        <!-- DESCRIPTION -->
        <meta name="description" content="LuxuryHotel : Premium Hotel Booking" />

        <!-- OG -->
        <meta property="og:title" content="LuxuryHotel : Premium Hotel Booking" />
        <meta property="og:description" content="LuxuryHotel : Premium Hotel Booking" />
        <meta property="og:image" content="" />
        <meta name="format-detection" content="telephone=no">

        <!-- FAVICONS ICON ============================================= -->
        <link rel="icon" href="${pageContext.request.contextPath}/assets/images/favicon.ico" type="image/x-icon" />
        <link rel="shortcut icon" type="image/x-icon" href="${pageContext.request.contextPath}/assets/images/favicon.png" />

        <!-- PAGE TITLE HERE ============================================= -->
        <title>LuxuryHotel | Booking Confirmation</title>

        <!-- MOBILE SPECIFIC ============================================= -->
        <meta name="viewport" content="width=device-width, initial-scale=1">

        <!-- All PLUGINS CSS ============================================= -->
        <link rel="stylesheet" type="text/css" href="${pageContext.request.contextPath}/assets/css/assets.css">

        <!-- TYPOGRAPHY ============================================= -->
        <link rel="stylesheet" type="text/css" href="${pageContext.request.contextPath}/assets/css/typography.css">

        <!-- SHORTCODES ============================================= -->
        <link rel="stylesheet" type="text/css" href="${pageContext.request.contextPath}/assets/css/shortcodes/shortcodes.css">

        <!-- STYLESHEETS ============================================= -->
        <link rel="stylesheet" type="text/css" href="${pageContext.request.contextPath}/assets/css/style.css">
        <link class="skin" rel="stylesheet" type="text/css" href="${pageContext.request.contextPath}/assets/css/color/color-1.css">
        
        <style>
            .confirmation-box {
                background: white;
                padding: 40px;
                border-radius: 10px;
                box-shadow: 0 0 20px rgba(0,0,0,0.1);
                text-align: center;
                margin: 50px auto;
                max-width: 800px;
            }
            
            .success-icon {
                width: 80px;
                height: 80px;
                background: #4CAF50;
                border-radius: 50%;
                display: flex;
                align-items: center;
                justify-content: center;
                margin: 0 auto 30px;
            }
            
            .success-icon i {
                color: white;
                font-size: 40px;
            }
            
            .booking-details {
                background: #f8f9fa;
                padding: 30px;
                border-radius: 10px;
                margin: 30px 0;
                text-align: left;
            }
            
            .detail-row {
                display: flex;
                justify-content: space-between;
                padding: 10px 0;
                border-bottom: 1px solid #eee;
            }
            
            .detail-row:last-child {
                border-bottom: none;
            }
            
            .detail-label {
                font-weight: 600;
                color: #666;
            }
            
            .detail-value {
                color: #333;
            }
            
            .booking-actions {
                margin-top: 30px;
            }
            
            .booking-actions .btn {
                margin: 0 10px;
            }
            
            .booking-id {
                font-size: 24px;
                color: #ff6b6b;
                font-weight: 600;
                margin: 10px 0;
            }
            
            .qr-code {
                margin: 20px auto;
                width: 150px;
                height: 150px;
                background: #f0f0f0;
                display: flex;
                align-items: center;
                justify-content: center;
                border-radius: 10px;
            }
            
            .print-section {
                display: none;
            }
            
            @media print {
                .no-print {
                    display: none !important;
                }
                
                .print-section {
                    display: block;
                }
                
                .confirmation-box {
                    box-shadow: none;
                    margin: 0;
                    max-width: 100%;
                }
            }
        </style>
    </head>
    <body id="bg">
        <div class="page-wraper">
            <div id="loading-icon-bx"></div>

            <!-- Header Top ==== -->
            <jsp:include page="header.jsp" />
            <!-- header END ==== -->

            <%
                Reservation reservation = (Reservation) request.getAttribute("reservation");
                Room room = (Room) request.getAttribute("room");
                RoomType roomType = (RoomType) request.getAttribute("roomType");
                Payment payment = (Payment) request.getAttribute("payment");
                List<ServiceOrder> services = (List<ServiceOrder>) request.getAttribute("services");
                
                DecimalFormat df = new DecimalFormat("#,###");
                SimpleDateFormat dateFormat = new SimpleDateFormat("dd/MM/yyyy");
                
                // Calculate nights
                long diffInMillies = reservation.getCheckOut().getTime() - reservation.getCheckIn().getTime();
                int nights = (int) (diffInMillies / (1000 * 60 * 60 * 24));
            %>
            
            <!-- Content -->
            <div class="page-content bg-white">
                <!-- inner page banner -->
                <div class="page-banner ovbl-dark" style="background-image:url(assets/images/banner/banner2.jpg);">
                    <div class="container">
                        <div class="page-banner-entry">
                            <h1 class="text-white">Booking Confirmation</h1>
                        </div>
                    </div>
                </div>
                
                <!-- Breadcrumb row -->
                <div class="breadcrumb-row">
                    <div class="container">
                        <ul class="list-inline">
                            <li><a href="#">Home</a></li>
                            <li><a href="RoomListServlet">Room List</a></li>
                            <li>Booking Confirmation</li>
                        </ul>
                    </div>
                </div>
                
                <!-- Confirmation Section -->
                <div class="section-area section-sp1">
                    <div class="container">
                        <div class="confirmation-box">
                            <div class="success-icon">
                                <i class="fa fa-check"></i>
                            </div>
                            
                            <h2 class="mb-3">Booking Confirmed!</h2>
                            <p class="text-muted mb-4">
                                Thank you for choosing LuxuryHotel. Your booking has been successfully confirmed.
                            </p>
                            
                            <div class="booking-id">
                                Booking ID: #<%= reservation.getId() %>
                            </div>
                            
                            <div class="qr-code">
                                <i class="fa fa-qrcode" style="font-size: 60px; color: #999;"></i>
                            </div>
                            <p class="text-muted small">Scan this QR code at reception for quick check-in</p>
                            
                            <div class="booking-details">
                                <h4 class="mb-4">Booking Details</h4>
                                
                                <div class="detail-row">
                                    <span class="detail-label">Guest Name:</span>
                                    <span class="detail-value"><%= reservation.getCustomerName() %></span>
                                </div>
                                
                                <div class="detail-row">
                                    <span class="detail-label">Email:</span>
                                    <span class="detail-value"><%= reservation.getCustomerEmail() %></span>
                                </div>
                                
                                <div class="detail-row">
                                    <span class="detail-label">Phone:</span>
                                    <span class="detail-value"><%= reservation.getCustomerPhone() %></span>
                                </div>
                                
                                <div class="detail-row">
                                    <span class="detail-label">Room Type:</span>
                                    <span class="detail-value"><%= roomType.getName() %></span>
                                </div>
                                
                                <div class="detail-row">
                                    <span class="detail-label">Room Number:</span>
                                    <span class="detail-value"><%= room.getRoomNumber() %></span>
                                </div>
                                
                                <div class="detail-row">
                                    <span class="detail-label">Check-in Date:</span>
                                    <span class="detail-value"><%= dateFormat.format(reservation.getCheckIn()) %></span>
                                </div>
                                
                                <div class="detail-row">
                                    <span class="detail-label">Check-out Date:</span>
                                    <span class="detail-value"><%= dateFormat.format(reservation.getCheckOut()) %></span>
                                </div>
                                
                                <div class="detail-row">
                                    <span class="detail-label">Number of Nights:</span>
                                    <span class="detail-value"><%= nights %></span>
                                </div>
                                
                                <div class="detail-row">
                                    <span class="detail-label">Number of Guests:</span>
                                    <span class="detail-value"><%= reservation.getNumberOfCustomers() %></span>
                                </div>
                                
                                <% if (services != null && !services.isEmpty()) { %>
                                <div class="detail-row">
                                    <span class="detail-label">Additional Services:</span>
                                    <span class="detail-value">
                                        <% for (ServiceOrder service : services) { %>
                                            <%= service.getServiceName() %><br>
                                        <% } %>
                                    </span>
                                </div>
                                <% } %>
                                
                                <% if (reservation.getSpecialRequests() != null && !reservation.getSpecialRequests().isEmpty()) { %>
                                <div class="detail-row">
                                    <span class="detail-label">Special Requests:</span>
                                    <span class="detail-value"><%= reservation.getSpecialRequests() %></span>
                                </div>
                                <% } %>
                                
                                <div class="detail-row">
                                    <span class="detail-label">Payment Method:</span>
                                    <span class="detail-value">
                                        <% if (payment != null) { %>
                                            <%= payment.getMethod().replace("_", " ") %>
                                        <% } else { %>
                                            Pay at Hotel
                                        <% } %>
                                    </span>
                                </div>
                                
                                <div class="detail-row">
                                    <span class="detail-label">Payment Status:</span>
                                    <span class="detail-value">
                                        <% if (payment != null && "SUCCESS".equals(payment.getStatus())) { %>
                                            <span class="badge badge-success">Paid</span>
                                        <% } else { %>
                                            <span class="badge badge-warning">Pending</span>
                                        <% } %>
                                    </span>
                                </div>
                                
                                <div class="detail-row">
                                    <span class="detail-label"><strong>Total Amount:</strong></span>
                                    <span class="detail-value"><strong><%= df.format(reservation.getTotalAmount()) %>₫</strong></span>
                                </div>
                            </div>
                            
                            <div class="booking-actions no-print">
                                <button onclick="window.print()" class="btn btn-secondary">
                                    <i class="fa fa-print"></i> Print Confirmation
                                </button>
                                <a href="RoomListServlet" class="btn">
                                    <i class="fa fa-home"></i> Back to Rooms
                                </a>
                            </div>
                            
                            <div class="mt-4">
                                <h5>Important Information:</h5>
                                <ul class="list-arrow primary text-left">
                                    <li>Check-in time: 14:00 - Check-out time: 12:00</li>
                                    <li>Please bring a valid ID and this confirmation when checking in</li>
                                    <li>For any changes or cancellations, please contact us at least 3 days before check-in</li>
                                    <li>A confirmation email has been sent to <%= reservation.getCustomerEmail() %></li>
                                </ul>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
            <!-- Content END-->

            <!-- Footer ==== -->
            <jsp:include page="footer.jsp" />
            <!-- Footer END ==== -->
            <button class="back-to-top fa fa-chevron-up" ></button>
        </div>

        <!-- External JavaScripts -->
        <script src="${pageContext.request.contextPath}/assets/js/jquery.min.js"></script>
        <script src="${pageContext.request.contextPath}/assets/vendors/bootstrap/js/popper.min.js"></script>
        <script src="${pageContext.request.contextPath}/assets/vendors/bootstrap/js/bootstrap.min.js"></script>
        <script src="${pageContext.request.contextPath}/assets/vendors/bootstrap-select/bootstrap-select.min.js"></script>
        <script src="${pageContext.request.contextPath}/assets/vendors/bootstrap-touchspin/jquery.bootstrap-touchspin.js"></script>
        <script src="${pageContext.request.contextPath}/assets/vendors/magnific-popup/magnific-popup.js"></script>
        <script src="${pageContext.request.contextPath}/assets/vendors/counter/waypoints-min.js"></script>
        <script src="${pageContext.request.contextPath}/assets/vendors/counter/counterup.min.js"></script>
        <script src="${pageContext.request.contextPath}/assets/vendors/imagesloaded/imagesloaded.js"></script>
        <script src="${pageContext.request.contextPath}/assets/vendors/masonry/masonry.js"></script>
        <script src="${pageContext.request.contextPath}/assets/vendors/masonry/filter.js"></script>
        <script src="${pageContext.request.contextPath}/assets/vendors/owl-carousel/owl.carousel.js"></script>
        <script src="${pageContext.request.contextPath}/assets/js/jquery.scroller.js"></script>
        <script src="${pageContext.request.contextPath}/assets/js/functions.js"></script>
        <script src="${pageContext.request.contextPath}/assets/js/contact.js"></script>
        <script src="${pageContext.request.contextPath}/assets/vendors/switcher/switcher.js"></script>
    </body>
</html>