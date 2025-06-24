<%-- 
    Document   : roomDetail
    Created on : 27 thg 5, 2025, 21:08:30
    Author     : ASUS
--%>

<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@ page import="model.RoomType" %>
<%@ page import="model.Room" %>
<%@ page import="model.Service" %>
<%@ page import="dal.RoomTypeDAO" %>
<%@ page import="dal.RoomDAO" %>
<%@ page import="dal.ServiceDAO" %>
<%@ page import="java.util.List" %>
<%@ page import="java.util.Arrays" %>
<%@ page import="java.text.DecimalFormat" %>
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
        <title>LuxuryHotel | Room Detail & Booking</title>

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

        <!-- Custom CSS for booking form -->
        <style>
            .booking-section {
                background-color: #f8f9fa;
                padding: 50px 0;
            }

            .booking-form {
                background: white;
                padding: 30px;
                border-radius: 10px;
                box-shadow: 0 0 20px rgba(0,0,0,0.1);
            }

            .room-gallery {
                margin-bottom: 30px;
            }

            .room-gallery .main-image {
                width: 100%;
                height: 400px;
                object-fit: cover;
                border-radius: 10px;
            }

            .room-thumbnails {
                display: flex;
                gap: 10px;
                margin-top: 10px;
            }

            .room-thumbnails img {
                width: 100px;
                height: 70px;
                object-fit: cover;
                border-radius: 5px;
                cursor: pointer;
                opacity: 0.7;
                transition: opacity 0.3s;
            }

            .room-thumbnails img:hover,
            .room-thumbnails img.active {
                opacity: 1;
            }

            .room-features {
                display: flex;
                flex-wrap: wrap;
                gap: 20px;
                margin: 20px 0;
            }

            .room-features .feature {
                display: flex;
                align-items: center;
                gap: 10px;
                color: #666;
            }

            .room-features .feature i {
                color: #ff6b6b;
            }

            .booking-summary {
                background: #f8f9fa;
                padding: 25px;
                border-radius: 10px;
                position: sticky;
                top: 20px;
            }

            .form-group {
                margin-bottom: 20px;
            }

            .form-group label {
                display: block;
                margin-bottom: 8px;
                font-weight: 500;
                color: #333;
            }

            .form-control {
                width: 100%;
                padding: 10px 15px;
                border: 1px solid #ddd;
                border-radius: 5px;
                font-size: 14px;
                transition: border-color 0.3s;
            }

            .form-control:focus {
                outline: none;
                border-color: #ff6b6b;
            }

            .form-control.is-invalid {
                border-color: #dc3545;
            }

            .invalid-feedback {
                display: none;
                color: #dc3545;
                font-size: 12px;
                margin-top: 5px;
            }

            .guest-counter {
                display: flex;
                align-items: center;
                justify-content: space-between;
                padding: 10px 0;
            }

            .counter-controls {
                display: flex;
                align-items: center;
                gap: 15px;
            }

            .counter-btn {
                width: 30px;
                height: 30px;
                border: 1px solid #ddd;
                background: white;
                border-radius: 50%;
                display: flex;
                align-items: center;
                justify-content: center;
                cursor: pointer;
                transition: all 0.3s;
            }

            .counter-btn:hover {
                background: #ff6b6b;
                color: white;
                border-color: #ff6b6b;
            }

            .service-item {
                border: 1px solid #eee;
                padding: 15px;
                border-radius: 8px;
                margin-bottom: 10px;
                cursor: pointer;
                transition: all 0.3s;
                display: flex;
                justify-content: space-between;
                align-items: center;
            }

            .service-item:hover {
                border-color: #ff6b6b;
                background: #fff5f5;
            }

            .service-item input[type="checkbox"] {
                margin-right: 10px;
            }

            .service-info {
                flex: 1;
            }

            .service-price {
                color: #ff6b6b;
                font-weight: 600;
            }

            .price-breakdown {
                border-top: 1px solid #eee;
                padding-top: 15px;
                margin-top: 15px;
            }

            .price-row {
                display: flex;
                justify-content: space-between;
                margin-bottom: 10px;
                color: #666;
            }

            .total-price {
                display: flex;
                justify-content: space-between;
                font-size: 20px;
                font-weight: 600;
                color: #333;
                margin-top: 15px;
                padding-top: 15px;
                border-top: 2px solid #eee;
            }

            .book-now-btn {
                width: 100%;
                padding: 15px;
                background: #ff6b6b;
                color: white;
                border: none;
                border-radius: 5px;
                font-size: 16px;
                font-weight: 600;
                cursor: pointer;
                transition: background 0.3s;
                margin-top: 20px;
            }

            .book-now-btn:hover {
                background: #e85555;
            }

            .book-now-btn:disabled {
                background: #ccc;
                cursor: not-allowed;
            }

            .amenity-item {
                display: flex;
                align-items: center;
                gap: 10px;
                margin-bottom: 8px;
            }

            .amenity-item i {
                color: #4CAF50;
            }

            .steps-indicator {
                display: flex;
                align-items: center;
                justify-content: center;
                margin-bottom: 30px;
            }

            .step {
                width: 40px;
                height: 40px;
                border-radius: 50%;
                display: flex;
                align-items: center;
                justify-content: center;
                font-weight: 600;
                color: white;
                background: #ff6b6b;
                position: relative;
            }

            .step:not(:last-child)::after {
                content: '';
                position: absolute;
                right: -50px;
                width: 50px;
                height: 2px;
                background: #ff6b6b;
            }

            .step.inactive {
                background: #ddd;
                color: #999;
            }

            .step.inactive::after {
                background: #ddd;
            }

            /* Availability Status Styles */
            .availability-status {
                background: #f8f9fa;
                border-radius: 10px;
                padding: 20px;
                margin-top: 20px;
            }

            .availability-badge {
                display: inline-flex;
                align-items: center;
                gap: 10px;
                padding: 15px 30px;
                border-radius: 50px;
                font-size: 18px;
                font-weight: 500;
            }

            .availability-badge.available {
                background: #d4edda;
                color: #155724;
                border: 1px solid #c3e6cb;
            }

            .availability-badge.unavailable {
                background: #f8d7da;
                color: #721c24;
                border: 1px solid #f5c6cb;
            }

            .availability-details {
                margin-top: 20px;
                padding: 20px;
                background: white;
                border-radius: 8px;
                border: 1px solid #dee2e6;
            }

            .availability-details h5 {
                color: #333;
                margin-bottom: 15px;
            }

            .availability-info {
                display: flex;
                justify-content: space-between;
                align-items: center;
                padding: 10px 0;
                border-bottom: 1px solid #eee;
            }

            .availability-info:last-child {
                border-bottom: none;
            }

            .availability-info span:first-child {
                color: #666;
            }

            .availability-info span:last-child {
                font-weight: 600;
                color: #333;
            }

            /* Alert styles */
            .alert {
                padding: 15px;
                margin-bottom: 20px;
                border: 1px solid transparent;
                border-radius: 4px;
            }

            .alert-info {
                color: #31708f;
                background-color: #d9edf7;
                border-color: #bce8f1;
            }

            .alert-success {
                color: #3c763d;
                background-color: #dff0d8;
                border-color: #d6e9c6;
            }

            .alert-warning {
                color: #8a6d3b;
                background-color: #fcf8e3;
                border-color: #faebcc;
            }

            .alert-danger {
                color: #a94442;
                background-color: #f2dede;
                border-color: #ebccd1;
            }

            .alert-dismissible {
                padding-right: 35px;
            }

            .alert-dismissible .close {
                position: absolute;
                top: 0;
                right: 0;
                padding: 15px;
                color: inherit;
                background: none;
                border: none;
                cursor: pointer;
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
                RoomTypeDAO dao = new RoomTypeDAO();
                ServiceDAO serviceDAO = new ServiceDAO();
                String idStr = (String) request.getAttribute("id");
                int id = Integer.parseInt(idStr);
                RoomType roomTypes = (RoomType) request.getAttribute("roomTypes"); 
                String description = roomTypes.getDescription();
                String features[] = description.split(",");
                String firstFeature = "";
                if (features.length > 0) {
                    firstFeature = features[0].trim();
                }
                
                // Get all active services
                List<Service> services = serviceDAO.getAllActiveServices();
                
                // Format price
                DecimalFormat df = new DecimalFormat("#,###");
                String formattedPrice = df.format(roomTypes.getBasePrice());
            %>

            <!-- Content -->
            <div class="page-content bg-white">
                <!-- inner page banner -->
                <div class="page-banner ovbl-dark" style="background-image:url(assets/images/banner/banner2.jpg);">
                    <div class="container">
                        <div class="page-banner-entry">
                            <h1 class="text-white">Book Your Room</h1>
                        </div>
                    </div>
                </div>

                <!-- Breadcrumb row -->
                <div class="breadcrumb-row">
                    <div class="container">
                        <ul class="list-inline">
                            <li><a href="#">Home</a></li>
                            <li><a href="RoomListServlet">Room List</a></li>
                            <li>Room Booking</li>
                        </ul>
                    </div>
                </div>

                <!-- Booking Section -->
                <div class="section-area section-sp1 booking-section">
                    <div class="container">
                    

                        <div class="row">
                            <!-- Left Column - Room Details & Booking Form -->
                            <div class="col-lg-8">
                                <div class="booking-form">
                                    <!-- Room Gallery -->
                                    <div class="room-gallery">
                                        <img id="mainImage" src="${pageContext.request.contextPath}/assets/images/uploads/<%= roomTypes.getImageUrl() %>" 
                                             alt="<%= roomTypes.getName() %>" class="main-image">
                                       
                                    </div>

                                    <!-- Room Info -->
                                    <div class="room-info mb-4">
                                        <div class="d-flex justify-content-between align-items-start mb-3">
                                            <div>
                                                <h2 class="post-title mb-2"><%= roomTypes.getName() %></h2>
                                                <div class="rating">
                                                    <i class="fa fa-star text-warning"></i>
                                                    <i class="fa fa-star text-warning"></i>
                                                    <i class="fa fa-star text-warning"></i>
                                                    <i class="fa fa-star text-warning"></i>
                                                    <i class="fa fa-star-half-o text-warning"></i>
                                                    <span class="text-muted ml-2">4.5 (128 reviews)</span>
                                                </div>
                                            </div>
                                            <div class="text-right">
                                                <h3 class="text-primary mb-0"><%= formattedPrice %>₫</h3>
                                                <span class="text-muted">/night</span>
                                            </div>
                                        </div>

                                        <!-- Room Features -->
                                        <div class="room-features">
                                            <div class="feature">
                                                <i class="ti-user"></i>
                                                <span><%= roomTypes.getCapacity() %> Guests</span>
                                            </div>
                                            <div class="feature">
                                                <i class="ti-home"></i>
                                                <span><%= firstFeature %></span>
                                            </div>
                                            <div class="feature">
                                                <i class="ti-ruler-pencil"></i>
                                                <span>45m²</span>
                                            </div>
                                            <div class="feature">
                                                <i class="ti-location-pin"></i>
                                                <span>Floor 15-20</span>
                                            </div>
                                        </div>
                                    </div>

                                    <!-- Room Description -->
                                    <div class="mb-4">
                                        <h4>Room Description</h4>
                                        <p class="text-muted">
                                            <%= roomTypes.getName() %> offers luxurious space and world-class amenities. 
                                            With an area of 45m², the room is elegantly designed with premium furniture, 
                                            comfortable King size bed along with luxury bedding set, creating a wonderful relaxation experience.
                                        </p>
                                        <p class="text-muted">
                                            The room has a private balcony with panoramic city views, marble bathroom with 
                                            separate bathtub and shower, fully stocked minibar and many other modern amenities.
                                        </p>
                                    </div>

                                    <!-- Room Amenities -->
                                    <div class="mb-4">
                                        <h4>Room Amenities</h4>
                                        <div class="row">
                                            <div class="col-md-6">
                                                <%
                                                    if (features.length > 1) {
                                                        for(int i = 1; i < Math.min(features.length, 6); i++){
                                                %>
                                                <div class="amenity-item">
                                                    <i class="fa fa-check"></i>
                                                    <span><%= features[i].trim() %></span>
                                                </div>
                                                <%
                                                        }
                                                    }
                                                %>
                                            </div>
                                            <div class="col-md-6">
                                                <div class="amenity-item">
                                                    <i class="fa fa-check"></i>
                                                    <span>Smart TV 55 inch</span>
                                                </div>
                                                <div class="amenity-item">
                                                    <i class="fa fa-check"></i>
                                                    <span>Free WiFi</span>
                                                </div>
                                                <div class="amenity-item">
                                                    <i class="fa fa-check"></i>
                                                    <span>Safe box</span>
                                                </div>
                                                <div class="amenity-item">
                                                    <i class="fa fa-check"></i>
                                                    <span>Coffee maker</span>
                                                </div>
                                                <div class="amenity-item">
                                                    <i class="fa fa-check"></i>
                                                    <span>Bathrobe</span>
                                                </div>
                                            </div>
                                        </div>
                                    </div>

                                    <!-- Booking Form -->
                                    <form id="bookingForm" action="BookingServlet" method="POST">
                                        <input type="hidden" name="roomTypeId" value="<%= id %>">
                                        <input type="hidden" name="basePrice" value="<%= roomTypes.getBasePrice() %>">
                                        <input type="hidden" name="selectedRoom" id="selectedRoom" value="">

                                        <h4 class="mb-3">Booking Information</h4>

                                        <!-- Date Selection -->
                                        <div class="row mb-4">
                                            <div class="col-md-6">
                                                <div class="form-group">
                                                    <label>Check-in Date</label>
                                                    <input type="date" name="checkinDate" class="form-control" required 
                                                           min="<%= new java.sql.Date(System.currentTimeMillis()) %>"
                                                           onchange="updateCheckoutMin()">
                                                </div>
                                            </div>
                                            <div class="col-md-6">
                                                <div class="form-group">
                                                    <label>Check-out Date</label>
                                                    <input type="date" name="checkoutDate" class="form-control" required
                                                           onchange="calculateNights()">
                                                </div>
                                            </div>
                                        </div>

                                        <!-- Guest Selection -->
                                        <div class="mb-4">
                                            <label>Number of Guests</label>
                                            <div class="guest-counter">
                                                <div>
                                                    <span>Adults</span>
                                                </div>
                                                <div class="counter-controls">
                                                    <button type="button" class="counter-btn" onclick="updateGuests('adults', -1)">
                                                        <i class="ti-minus"></i>
                                                    </button>
                                                    <span id="adultsCount">2</span>
                                                    <input type="hidden" name="adults" id="adultsInput" value="2">
                                                    <button type="button" class="counter-btn" onclick="updateGuests('adults', 1)">
                                                        <i class="ti-plus"></i>
                                                    </button>
                                                </div>
                                            </div>
                                            <div class="guest-counter">
                                                <div>
                                                    <span>Children (under 12)</span>
                                                </div>
                                                <div class="counter-controls">
                                                    <button type="button" class="counter-btn" onclick="updateGuests('children', -1)">
                                                        <i class="ti-minus"></i>
                                                    </button>
                                                    <span id="childrenCount">0</span>
                                                    <input type="hidden" name="children" id="childrenInput" value="0">
                                                    <button type="button" class="counter-btn" onclick="updateGuests('children', 1)">
                                                        <i class="ti-plus"></i>
                                                    </button>
                                                </div>
                                            </div>
                                        </div>

                                        <!-- Additional Services -->
                                        <div class="mb-4">
                                            <h4>Additional Services</h4>
                                            <% for(Service service : services) { %>
                                            <div class="service-item">
                                                <label style="display: flex; align-items: center; width: 100%; cursor: pointer; margin: 0;">
                                                    <input type="checkbox" name="services" value="<%= service.getId() %>" 
                                                           data-price="<%= service.getPrice() %>" onchange="updateTotalPrice()">
                                                    <div class="service-info">
                                                        <strong><%= service.getName() %></strong>
                                                        <div class="text-muted small"><%= service.getDescription() %></div>
                                                    </div>
                                                    <div class="service-price">
                                                        <%= df.format(service.getPrice()) %>₫
                                                    </div>
                                                </label>
                                            </div>
                                            <% } %>
                                        </div>

                                        <!-- Contact Information -->
                                        <div class="mb-4">
                                            <h4>Contact Information</h4>
                                            <div class="row">
                                                <div class="col-md-6">
                                                    <div class="form-group">
                                                        <label>Full Name *</label>
                                                        <input type="text" name="fullName" class="form-control" required>
                                                    </div>
                                                </div>
                                                <div class="col-md-6">
                                                    <div class="form-group">
                                                        <label>Email *</label>
                                                        <input type="email" name="email" class="form-control" required>
                                                    </div>
                                                </div>
                                                <div class="col-md-6">
                                                    <div class="form-group">
                                                        <label>Phone Number *</label>
                                                        <input type="tel" name="phone" class="form-control" required>
                                                    </div>
                                                </div>
                                                <div class="col-md-6">
                                                    <div class="form-group">
                                                        <label>Nationality</label>
                                                        <select name="nationality" class="form-control">
                                                            <option value="VN">Vietnam</option>
                                                            <option value="US">United States</option>
                                                            <option value="KR">South Korea</option>
                                                            <option value="JP">Japan</option>
                                                            <option value="CN">China</option>
                                                            <option value="Other">Other</option>
                                                        </select>
                                                    </div>
                                                </div>
                                            </div>
                                            <div class="form-group">
                                                <label>Special Requests</label>
                                                <textarea name="specialRequests" class="form-control" rows="3" 
                                                          placeholder="Please let us know if you have any special requests..."></textarea>
                                            </div>
                                        </div>

                                        <!-- Payment Method -->
                                        <div class="mb-4">
                                            <h4>Payment Method</h4>
                                            <div class="form-check mb-2">
                                                <input class="form-check-input" type="radio" name="paymentMethod" value="CREDIT_CARD" id="creditCardForm" checked>
                                                <label class="form-check-label" for="creditCardForm">
                                                    Credit/Debit Card
                                                </label>
                                            </div>
                                            <div class="form-check mb-2">
                                                <input class="form-check-input" type="radio" name="paymentMethod" value="BANK_TRANSFER" id="bankTransferForm">
                                                <label class="form-check-label" for="bankTransferForm">
                                                    Bank Transfer
                                                </label>
                                            </div>
                                            <div class="form-check mb-2">
                                                <input class="form-check-input" type="radio" name="paymentMethod" value="CASH" id="payAtHotelForm">
                                                <label class="form-check-label" for="payAtHotelForm">
                                                    Pay at Hotel
                                                </label>
                                            </div>
                                        </div>
                                    </form>
                                </div>
                            </div>

                            <!-- Right Column - Booking Summary -->
                            <div class="col-lg-4">
                                <div class="booking-summary">
                                    <h4 class="mb-4">Booking Summary</h4>

                                    <div class="mb-3 pb-3 border-bottom">
                                        <h5><%= roomTypes.getName() %></h5>
                                        <p class="text-muted mb-1"><span id="nightsDisplay">1</span> night(s), <span id="guestsDisplay">2 adults</span></p>
                                    </div>

                                    <div class="price-breakdown">
                                        <div class="price-row">
                                            <span>Room price (<span id="nightsText">1</span> night)</span>
                                            <span id="roomPriceDisplay"><%= formattedPrice %>₫</span>
                                        </div>
                                        <div class="price-row">
                                            <span>Taxes & fees (10%)</span>
                                            <span id="taxDisplay">0₫</span>
                                        </div>
                                        <div id="servicesDisplay"></div>
                                    </div>

                                    <div class="total-price">
                                        <span>Total</span>
                                        <span id="totalPriceDisplay">0₫</span>
                                    </div>

                                    <!-- Terms and Conditions -->
                                    <div class="form-check mt-4 mb-4">
                                        <input class="form-check-input" type="checkbox" id="termsCheck" required>
                                        <label class="form-check-label" for="termsCheck">
                                            I agree to the <a href="#" class="text-primary">terms and conditions</a>
                                        </label>
                                    </div>

                                    <button type="submit" form="bookingForm" class="book-now-btn">
                                        Confirm Booking
                                    </button>

                                    <div class="text-center mt-3">
                                        <small class="text-muted">
                                            <i class="fa fa-shield"></i> Secure payment & privacy protected<br>
                                            You won't be charged until confirmation
                                        </small>
                                    </div>
                                </div>
                            </div>
                        </div>

                        <!-- Room Policy -->
                        <div class="mt-5 booking-form">
                            <h4>Room Policy</h4>
                            <ul class="list-arrow primary">
                                <li>Check-in from 14:00, check-out before 12:00</li>
                                <li>Free cancellation up to 3 days before arrival, then 50% charge</li>
                                <li>Breakfast included for 2 guests</li>
                                <li>Non-smoking room</li>
                                <li>Daily room cleaning service</li>
                                <li>24/7 security</li>
                                <li>Near shopping centers and entertainment venues</li>
                            </ul>
                        </div>

                        <!-- Room Availability Check -->
                        <div class="mt-5">
                            <h3 class="mb-4">Room Availability</h3>
                            <div class="alert alert-info">
                                <i class="fa fa-info-circle"></i> <strong>Note:</strong> Room assignment will be done by our reception staff during check-in to ensure you get the best available room.
                            </div>
                            <div class="availability-status" id="availabilityStatus">
                                <div class="text-center p-4">
                                    <i class="fa fa-calendar-check-o" style="font-size: 48px; color: #ddd;"></i>
                                    <p class="mt-3 text-muted">Please select your check-in and check-out dates to check availability</p>
                                </div>
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

        <!-- Custom JavaScript for booking functionality -->
        <script>
                                                               const basePrice = <%= roomTypes.getBasePrice() %>;
                                                               let nights = 1;
                                                               let adults = 2;
                                                               let children = 0;

                                                               function changeMainImage(img) {
                                                                   document.getElementById('mainImage').src = img.src;
                                                                   // Remove active class from all thumbnails
                                                                   document.querySelectorAll('.room-thumbnails img').forEach(thumb => {
                                                                       thumb.classList.remove('active');
                                                                   });
                                                                   // Add active class to clicked thumbnail
                                                                   img.classList.add('active');
                                                               }

                                                               function updateCheckoutMin() {
                                                                   const checkinDate = document.querySelector('input[name="checkinDate"]').value;
                                                                   const checkoutInput = document.querySelector('input[name="checkoutDate"]');

                                                                   if (checkinDate) {
                                                                       const checkin = new Date(checkinDate);
                                                                       checkin.setDate(checkin.getDate() + 1);
                                                                       const minCheckout = checkin.toISOString().split('T')[0];
                                                                       checkoutInput.setAttribute('min', minCheckout);

                                                                       // Reset checkout if it's before new minimum
                                                                       if (checkoutInput.value && checkoutInput.value < minCheckout) {
                                                                           checkoutInput.value = minCheckout;
                                                                       }
                                                                   }
                                                                   calculateNights();
                                                               }

                                                               function calculateNights() {
                                                                   const checkinDate = document.querySelector('input[name="checkinDate"]').value;
                                                                   const checkoutDate = document.querySelector('input[name="checkoutDate"]').value;

                                                                   if (checkinDate && checkoutDate) {
                                                                       const checkin = new Date(checkinDate);
                                                                       const checkout = new Date(checkoutDate);
                                                                       nights = Math.ceil((checkout - checkin) / (1000 * 60 * 60 * 24));

                                                                       document.getElementById('nightsDisplay').textContent = nights;
                                                                       document.getElementById('nightsText').textContent = nights;

                                                                       updateTotalPrice();

                                                                       // Check room availability for selected dates
                                                                       checkRoomAvailability(checkinDate, checkoutDate);
                                                                   }
                                                               }

                                                               function checkRoomAvailability(checkinDate, checkoutDate) {
                                                                   const roomTypeId = document.querySelector('input[name="roomTypeId"]').value;
                                                                   const contextPath = window.location.pathname.substring(0, window.location.pathname.indexOf('/', 1));

                                                                   // Show loading message
                                                                   const statusDiv = document.getElementById('availabilityStatus');
                                                                   if (statusDiv) {
                                                                       statusDiv.innerHTML = '<div class="text-center p-4"><i class="fa fa-spinner fa-spin" style="font-size: 48px; color: #ff6b6b;"></i><p class="mt-3">Checking availability...</p></div>';
                                                                   }

                                                                   // Make AJAX call to check availability
                                                                   fetch(contextPath + '/CheckRoomAvailability?roomTypeId=' + roomTypeId +
                                                                           '&checkIn=' + checkinDate + '&checkOut=' + checkoutDate)
                                                                           .then(response => response.json())
                                                                           .then(data => {
                                                                               updateAvailabilityStatus(data);
                                                                           })
                                                                           .catch(error => {
                                                                               console.error('Error checking availability:', error);
                                                                               if (statusDiv) {
                                                                                   statusDiv.innerHTML = '<div class="text-center p-4 text-danger"><i class="fa fa-exclamation-circle" style="font-size: 48px;"></i><p class="mt-3">Error checking availability. Please try again.</p></div>';
                                                                               }
                                                                           });
                                                               }

                                                               function updateAvailabilityStatus(data) {
                                                                   const statusDiv = document.getElementById('availabilityStatus');
                                                                   if (!statusDiv)
                                                                       return;

                                                                   if (data.available) {
                                                                       statusDiv.innerHTML = `
                        <div class="text-center">
                            <div class="availability-badge available">
                                <i class="fa fa-check-circle" style="font-size: 24px;"></i>
                                <span>Rooms Available!</span>
                            </div>
                            <div class="availability-details mt-4">
                                <h5>Availability Details</h5>
                                <div class="availability-info">
                                    <span>Room Type:</span>
                                    <span><%= roomTypes.getName() %></span>
                                </div>
                                <div class="availability-info">
                                    <span>Available Rooms:</span>
                                    <span>${data.availableCount || 'Multiple'} rooms</span>
                                </div>
                                <div class="availability-info">
                                    <span>Your Dates:</span>
                                    <span>${document.querySelector('input[name="checkinDate"]').value} to ${document.querySelector('input[name="checkoutDate"]').value}</span>
                                </div>
                            </div>
                            <p class="mt-3 text-success">
                                <i class="fa fa-info-circle"></i> Great! We have rooms available for your selected dates. 
                                Proceed with booking and our reception staff will assign you the best available room during check-in.
                            </p>
                        </div>
                    `;

                                                                       // Enable the booking button if it was disabled
                                                                       const bookingBtn = document.querySelector('.book-now-btn');
                                                                       if (bookingBtn) {
                                                                           bookingBtn.disabled = false;
                                                                           bookingBtn.textContent = 'Confirm Booking';
                                                                       }
                                                                   } else {
                                                                       statusDiv.innerHTML = `
                        <div class="text-center">
                            <div class="availability-badge unavailable">
                                <i class="fa fa-times-circle" style="font-size: 24px;"></i>
                                <span>No Rooms Available</span>
                            </div>
                            <p class="mt-3 text-danger">
                                <i class="fa fa-calendar-times-o"></i> Sorry, we don't have any <%= roomTypes.getName() %> rooms available for your selected dates.
                                Please try different dates or check other room types.
                            </p>
                            <div class="mt-4">
                                <a href="${window.location.pathname.substring(0, window.location.pathname.indexOf('/', 1))}/RoomListServlet" class="btn btn-primary">
                                    <i class="fa fa-search"></i> View Other Room Types
                                </a>
                            </div>
                        </div>
                    `;

                                                                       // Disable the booking button
                                                                       const bookingBtn = document.querySelector('.book-now-btn');
                                                                       if (bookingBtn) {
                                                                           bookingBtn.disabled = true;
                                                                           bookingBtn.textContent = 'No Rooms Available';
                                                                       }
                                                                   }
                                                               }

                                                               function updateGuests(type, change) {
                                                                   if (type === 'adults') {
                                                                       adults = Math.max(1, Math.min(4, adults + change));
                                                                       document.getElementById('adultsCount').textContent = adults;
                                                                       document.getElementById('adultsInput').value = adults;
                                                                   } else {
                                                                       children = Math.max(0, Math.min(3, children + change));
                                                                       document.getElementById('childrenCount').textContent = children;
                                                                       document.getElementById('childrenInput').value = children;
                                                                   }

                                                                   updateGuestsDisplay();
                                                               }

                                                               function updateGuestsDisplay() {
                                                                   let guestText = adults + ' adult' + (adults > 1 ? 's' : '');
                                                                   if (children > 0) {
                                                                       guestText += ', ' + children + ' child' + (children > 1 ? 'ren' : '');
                                                                   }
                                                                   document.getElementById('guestsDisplay').textContent = guestText;
                                                               }

                                                               function updateTotalPrice() {
                                                                   const roomPrice = basePrice * nights;
                                                                   const tax = roomPrice * 0.1;
                                                                   let servicesTotal = 0;
                                                                   let servicesHtml = '';

                                                                   // Calculate services total
                                                                   document.querySelectorAll('input[name="services"]:checked').forEach(checkbox => {
                                                                       const servicePrice = parseFloat(checkbox.getAttribute('data-price'));
                                                                       servicesTotal += servicePrice;

                                                                       const serviceName = checkbox.parentElement.querySelector('.service-info strong').textContent;
                                                                       servicesHtml += '<div class="price-row">' +
                                                                               '<span>' + serviceName + '</span>' +
                                                                               '<span>' + formatPrice(servicePrice) + '</span>' +
                                                                               '</div>';
                                                                   });

                                                                   const total = roomPrice + tax + servicesTotal;

                                                                   // Update display
                                                                   document.getElementById('roomPriceDisplay').textContent = formatPrice(roomPrice);
                                                                   document.getElementById('taxDisplay').textContent = formatPrice(tax);
                                                                   document.getElementById('servicesDisplay').innerHTML = servicesHtml;
                                                                   document.getElementById('totalPriceDisplay').textContent = formatPrice(total);
                                                               }

                                                               function formatPrice(price) {
                                                                   return new Intl.NumberFormat('vi-VN').format(price) + '₫';
                                                               }

                                                               function validateBookingForm() {
                                                                   console.log('Starting form validation...');

                                                                   // Check terms and conditions
                                                                   const termsCheck = document.getElementById('termsCheck');
                                                                   if (!termsCheck) {
                                                                       console.error('Terms checkbox not found');
                                                                       showAlert('Error: Terms checkbox not found', 'error');
                                                                       return false;
                                                                   }

                                                                   if (!termsCheck.checked) {
                                                                       showAlert('Please accept the terms and conditions', 'warning');
                                                                       return false;
                                                                   }

                                                                   // Check if room type is available (no need to select specific room)
                                                                   const bookingBtn = document.querySelector('.book-now-btn');
                                                                   if (bookingBtn && bookingBtn.disabled) {
                                                                       showAlert('No rooms available for selected dates', 'warning');
                                                                       return false;
                                                                   }

                                                                   // Validate dates
                                                                   const checkinDateInput = document.querySelector('input[name="checkinDate"]');
                                                                   const checkoutDateInput = document.querySelector('input[name="checkoutDate"]');

                                                                   if (!checkinDateInput || !checkoutDateInput) {
                                                                       console.error('Date inputs not found');
                                                                       showAlert('Error: Date inputs not found', 'error');
                                                                       return false;
                                                                   }

                                                                   const checkinDate = checkinDateInput.value;
                                                                   const checkoutDate = checkoutDateInput.value;

                                                                   if (!checkinDate || !checkoutDate) {
                                                                       showAlert('Please select both check-in and check-out dates', 'warning');
                                                                       return false;
                                                                   }

                                                                   // Validate guest information
                                                                   const fullNameInput = document.querySelector('input[name="fullName"]');
                                                                   const emailInput = document.querySelector('input[name="email"]');
                                                                   const phoneInput = document.querySelector('input[name="phone"]');

                                                                   if (!fullNameInput || !emailInput || !phoneInput) {
                                                                       console.error('Contact info inputs not found');
                                                                       showAlert('Error: Contact information inputs not found', 'error');
                                                                       return false;
                                                                   }

                                                                   const fullName = fullNameInput.value.trim();
                                                                   const email = emailInput.value.trim();
                                                                   const phone = phoneInput.value.trim();

                                                                   if (!fullName || !email || !phone) {
                                                                       showAlert('Please fill in all required contact information', 'warning');
                                                                       return false;
                                                                   }

                                                                   // Validate email format
                                                                   const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
                                                                   if (!emailRegex.test(email)) {
                                                                       showAlert('Please enter a valid email address', 'warning');
                                                                       return false;
                                                                   }

                                                                   // Validate phone format (Vietnamese phone number)
                                                                   const phoneRegex = /^(0|84|\+84)?[3456789]\d{8}$/;
                                                                   if (!phoneRegex.test(phone.replace(/\s/g, ''))) {
                                                                       showAlert('Please enter a valid phone number', 'warning');
                                                                       return false;
                                                                   }

                                                                   console.log('Form validation passed!');
                                                                   return true;
                                                               }

                                                               function checkLoginAndProceed() {
                                                                   showLoading(true);

                                                                   const contextPath = window.location.pathname.substring(0, window.location.pathname.indexOf('/', 1));
                                                                   const url = contextPath + '/BookingServlet?action=checkLogin';

                                                                   fetch(url)
                                                                           .then(response => {
                                                                               if (!response.ok) {
                                                                                   throw new Error('Server responded with status: ' + response.status);
                                                                               }
                                                                               return response.json();
                                                                           })
                                                                           .then(data => {
                                                                               if (data.isLoggedIn) {
                                                                                   // User is logged in - update form with user data if needed
                                                                                   updateFormWithUserData(data.user);
                                                                                   submitBookingForm();
                                                                               } else {
                                                                                   // User not logged in - proceed with guest booking
                                                                                   submitBookingForm();
                                                                               }
                                                                           })
                                                                           .catch(error => {
                                                                               showLoading(false);
                                                                               console.error('Error:', error);
                                                                               showAlert('An error occurred. Please try again.', 'error');
                                                                           });
                                                               }

                                                               function updateFormWithUserData(user) {
                                                                   if (user) {
                                                                       // Update form fields with logged-in user data
                                                                       if (user.fullName)
                                                                           document.querySelector('input[name="fullName"]').value = user.fullName;
                                                                       if (user.email)
                                                                           document.querySelector('input[name="email"]').value = user.email;
                                                                       if (user.phone)
                                                                           document.querySelector('input[name="phone"]').value = user.phone;
                                                                   }
                                                               }

                                                               function submitBookingForm() {
                                                                   console.log('submitBookingForm called');

                                                                   const form = document.getElementById('bookingForm');
                                                                   if (!form) {
                                                                       console.error('Form not found!');
                                                                       showAlert('Error: Booking form not found', 'error');
                                                                       return;
                                                                   }

                                                                   // Get form data manually
                                                                   const formData = {
                                                                       roomTypeId: form.roomTypeId.value,
                                                                       basePrice: form.basePrice.value,
                                                                       checkinDate: form.checkinDate.value,
                                                                       checkoutDate: form.checkoutDate.value,
                                                                       adults: form.adults.value,
                                                                       children: form.children.value,
                                                                       fullName: form.fullName.value,
                                                                       email: form.email.value,
                                                                       phone: form.phone.value,
                                                                       nationality: form.nationality.value,
                                                                       specialRequests: form.specialRequests.value,
                                                                       paymentMethod: form.paymentMethod.value
                                                                   };

                                                                   // Get selected services
                                                                   const selectedServices = [];
                                                                   document.querySelectorAll('input[name="services"]:checked').forEach(checkbox => {
                                                                       selectedServices.push(checkbox.value);
                                                                   });

                                                                   // Log form data for debugging
                                                                   console.log('=== Form Data ===');
                                                                   console.log(formData);
                                                                   console.log('Services:', selectedServices);

                                                                   // Check required fields
                                                                   const requiredFields = ['roomTypeId', 'basePrice', 'checkinDate', 'checkoutDate',
                                                                       'fullName', 'email', 'phone'];

                                                                   for (let field of requiredFields) {
                                                                       if (!formData[field]) {
                                                                           console.error('Missing required field: ' + field);
                                                                           showAlert('Missing required field: ' + field, 'error');
                                                                           return;
                                                                       }
                                                                   }

                                                                   // Calculate and add nights
                                                                   const checkinDate = new Date(formData.checkinDate);
                                                                   const checkoutDate = new Date(formData.checkoutDate);
                                                                   const nights = Math.ceil((checkoutDate - checkinDate) / (1000 * 60 * 60 * 24));
                                                                   formData.nights = nights;

                                                                   // Build URL encoded string
                                                                   let params = new URLSearchParams();
                                                                   for (let key in formData) {
                                                                       params.append(key, formData[key]);
                                                                   }

                                                                   // Add services
                                                                   selectedServices.forEach(serviceId => {
                                                                       params.append('services', serviceId);
                                                                   });

                                                                   console.log('Request params:', params.toString());

                                                                   // Get context path
                                                                   const contextPath = window.location.pathname.substring(0, window.location.pathname.indexOf('/', 1));
                                                                   const url = contextPath + '/BookingServlet';
                                                                   console.log('Context path:', contextPath);
                                                                   console.log('Posting to URL:', url);

                                                                   fetch(url, {
                                                                       method: 'POST',
                                                                       headers: {
                                                                           'Content-Type': 'application/x-www-form-urlencoded'
                                                                       },
                                                                       body: params.toString()
                                                                   })
                                                                           .then(response => {
                                                                               console.log('Response status:', response.status);
                                                                               console.log('Response headers:', response.headers);

                                                                               // Read response text first
                                                                               return response.text().then(text => {
                                                                                   console.log('Response text:', text);

                                                                                   // Check if response is OK
                                                                                   if (!response.ok) {
                                                                                       // Try to parse as JSON
                                                                                       try {
                                                                                           const errorData = JSON.parse(text);
                                                                                           throw new Error(errorData.error || 'Server responded with status: ' + response.status);
                                                                                       } catch (e) {
                                                                                           throw new Error('Server responded with status: ' + response.status);
                                                                                       }
                                                                                   }

                                                                                   // Parse as JSON
                                                                                   return JSON.parse(text);
                                                                               });
                                                                           })
                                                                           .then(data => {
                                                                               showLoading(false);
                                                                               console.log('Response data:', data);

                                                                               if (data.requireOTP) {
                                                                                   // Guest booking - show OTP modal
                                                                                   showOTPModal(data.email);
                                                                               } else if (data.success) {
                                                                                   // Booking successful
                                                                                   const paymentMethod = document.querySelector('input[name="paymentMethod"]:checked').value;
                                                                                   handleBookingSuccess(data, paymentMethod);
                                                                               } else {
                                                                                   showAlert(data.error || 'Booking failed. Please try again.', 'error');
                                                                               }
                                                                           })
                                                                           .catch(error => {
                                                                               showLoading(false);
                                                                               console.error('Error:', error);
                                                                               showAlert(error.message || 'An error occurred while processing your booking. Please try again.', 'error');
                                                                           });
                                                               }

                                                               function handleBookingSuccess(data, paymentMethod) {
                                                                   if (paymentMethod === 'CASH') {
                                                                       // For cash payment, redirect to confirmation page
                                                                       window.location.href = 'BookingConfirmation?reservationId=' + data.reservationId;
                                                                   } else {
                                                                       // For online payment, redirect to payment gateway
                                                                       window.location.href = 'PaymentGateway?reservationId=' + data.reservationId +
                                                                               '&paymentId=' + data.paymentId +
                                                                               '&method=' + paymentMethod;
                                                                   }
                                                               }

                                                               // Add these functions to your roomDetail.jsp JavaScript section

                                                          function showOTPModal(maskedEmail) {
    // Create modal HTML with improved styling
    const modalHTML = `
        <div id="otpModal" class="modal" style="display: block; position: fixed; z-index: 1000; left: 0; top: 0; width: 100%; height: 100%; background-color: rgba(0,0,0,0.5);">
            <div class="modal-content" style="background-color: #fefefe; margin: 5% auto; padding: 0; border: 1px solid #888; width: 90%; max-width: 450px; border-radius: 10px; box-shadow: 0 4px 20px rgba(0,0,0,0.3); max-height: 90vh; overflow-y: auto;">
                <div style="background: #ff6b6b; color: white; padding: 20px; border-radius: 10px 10px 0 0; position: sticky; top: 0; z-index: 1;">
                    <h3 style="margin: 0; text-align: center;">Email Verification Required</h3>
                </div>
                <div style="padding: 30px;">
                    <div style="text-align: center; margin-bottom: 20px;">
                        <i class="fa fa-envelope" style="font-size: 48px; color: #ff6b6b;"></i>
                    </div>
                    <p style="text-align: center; color: #333; margin-bottom: 10px;">
                        We've sent a verification code to
                    </p>
                    <p style="text-align: center; font-weight: bold; color: #ff6b6b; font-size: 18px; margin-bottom: 20px;">
                        ${maskedEmail}
                    </p>
                    <p style="text-align: center; color: #666; margin-bottom: 20px;">
                        Please enter the 6-digit code below:
                    </p>
                    <input type="text" id="otpInput" maxlength="6" pattern="[0-9]{6}" 
                           style="width: 100%; padding: 15px; font-size: 24px; text-align: center; letter-spacing: 10px; margin: 20px 0; border: 2px solid #ddd; border-radius: 5px; box-sizing: border-box;"
                           placeholder="000000"
                           onkeyup="handleOTPInput(event)">
                    <div id="otpError" style="color: #dc3545; text-align: center; margin-bottom: 20px; display: none;"></div>
                    <div style="text-align: center; margin-bottom: 20px;">
                        <button type="button" onclick="verifyOTP()" class="btn" style="margin-right: 10px; padding: 10px 30px; background: #ff6b6b; color: white; border: none; border-radius: 5px; font-size: 16px; cursor: pointer;">
                            Verify Code
                        </button>
                        <button type="button" onclick="resendOTP()" class="btn btn-secondary" style="padding: 10px 30px; background: #6c757d; color: white; border: none; border-radius: 5px; font-size: 16px; cursor: pointer;">
                            Resend Code
                        </button>
                    </div>
                    <div id="resendMessage" style="text-align: center; color: #28a745; display: none; margin-bottom: 10px;">
                        <i class="fa fa-check-circle"></i> New code sent successfully!
                    </div>
                    <p style="text-align: center; margin-top: 20px; color: #666; font-size: 14px;">
                        <i class="fa fa-info-circle"></i> Didn't receive the code? Check your spam folder or click Resend Code.
                    </p>
                    
                    <!-- Cancel button moved here for better visibility -->
                    <div style="text-align: center; margin-top: 30px; padding-top: 20px; border-top: 1px solid #eee;">
                        <button type="button" onclick="closeOTPModal()" style="background: #f8f9fa; border: 1px solid #dee2e6; color: #6c757d; cursor: pointer; font-size: 14px; padding: 10px 30px; border-radius: 5px;">
                            <i class="fa fa-times"></i> Cancel Booking
                        </button>
                    </div>
                </div>
            </div>
        </div>
    `;

                                                                   document.body.insertAdjacentHTML('beforeend', modalHTML);
                                                                   document.getElementById('otpInput').focus();

                                                                   // Auto-submit when 6 digits are entered
                                                                   document.getElementById('otpInput').addEventListener('input', function () {
                                                                       if (this.value.length === 6) {
                                                                           console.log('6 digits entered, auto-verifying...');
                                                                           verifyOTP();
                                                                       }
                                                                   });

                                                                   // Debug - check if functions are accessible
                                                                   console.log('OTP Modal created. Functions available:');
                                                                   console.log('verifyOTP:', typeof verifyOTP);
                                                                   console.log('resendOTP:', typeof resendOTP);
                                                                   console.log('closeOTPModal:', typeof closeOTPModal);
                                                               }

                                                               function handleOTPInput(event) {
                                                                   const input = event.target;
                                                                   // Only allow numbers
                                                                   input.value = input.value.replace(/[^0-9]/g, '');

                                                                   // Hide error message when typing
                                                                   document.getElementById('otpError').style.display = 'none';
                                                               }

                                                               function closeOTPModal() {
                                                                   const modal = document.getElementById('otpModal');
                                                                   if (modal) {
                                                                       modal.remove();
                                                                   }
                                                               }

                                                               function verifyOTP() {
                                                                   const otpInput = document.getElementById('otpInput');
                                                                   const otp = otpInput.value;
                                                                   const errorDiv = document.getElementById('otpError');

                                                                   // Validate OTP
                                                                   if (otp.length !== 6) {
                                                                       errorDiv.textContent = 'Please enter a 6-digit code';
                                                                       errorDiv.style.display = 'block';
                                                                       return;
                                                                   }

                                                                   // Get the verify button
                                                                   const verifyBtn = document.querySelector('button[onclick="verifyOTP()"]');
                                                                   const originalText = verifyBtn.innerHTML;
                                                                   verifyBtn.innerHTML = '<i class="fa fa-spinner fa-spin"></i> Verifying...';
                                                                   verifyBtn.disabled = true;

                                                                   const contextPath = getContextPath();
                                                                   const url = contextPath + '/ValidateOTP';

                                                                   fetch(url, {
                                                                       method: 'POST',
                                                                       headers: {
                                                                           'Content-Type': 'application/x-www-form-urlencoded',
                                                                       },
                                                                       body: 'otp=' + otp
                                                                   })
                                                                           .then(response => {
                                                                               if (!response.ok) {
                                                                                   throw new Error('Server responded with status: ' + response.status);
                                                                               }
                                                                               return response.json();
                                                                           })
                                                                           .then(data => {
                                                                               if (data.success) {
                                                                                   // OTP validated successfully
                                                                                   errorDiv.style.display = 'none';

                                                                                   // Show success message
                                                                                   verifyBtn.innerHTML = '<i class="fa fa-check"></i> Verified!';
                                                                                   verifyBtn.style.background = '#28a745';

                                                                                   // Close modal after a short delay
                                                                                   setTimeout(() => {
                                                                                       const modal = document.getElementById('otpModal');
                                                                                       if (modal) {
                                                                                           modal.remove();
                                                                                       }
                                                                                       // Resubmit the booking form
                                                                                       submitBookingForm();
                                                                                   }, 300);
                                                                               } else {
                                                                                   // Invalid OTP
                                                                                   errorDiv.textContent = data.message || 'Invalid code. Please try again.';
                                                                                   errorDiv.style.display = 'block';
                                                                                   otpInput.value = '';
                                                                                   otpInput.focus();

                                                                                   // Restore button
                                                                                   verifyBtn.innerHTML = originalText;
                                                                                   verifyBtn.disabled = false;
                                                                               }
                                                                           })
                                                                           .catch(error => {
                                                                               console.error('Error:', error);
                                                                               errorDiv.textContent = 'An error occurred. Please try again.';
                                                                               errorDiv.style.display = 'block';

                                                                               // Restore button
                                                                               verifyBtn.innerHTML = originalText;
                                                                               verifyBtn.disabled = false;
                                                                           });
                                                               }

                                                               function resendOTP() {
                                                                   const resendBtn = document.querySelector('button[onclick="resendOTP()"]');
                                                                   const originalText = resendBtn.innerHTML;
                                                                   const resendMessage = document.getElementById('resendMessage');

                                                                   // Show loading on resend button
                                                                   resendBtn.innerHTML = '<i class="fa fa-spinner fa-spin"></i> Sending...';
                                                                   resendBtn.disabled = true;

                                                                   const contextPath = getContextPath();
                                                                   const url = contextPath + '/ResendOTP';

                                                                   fetch(url, {
                                                                       method: 'POST'
                                                                   })
                                                                           .then(response => {
                                                                               if (!response.ok) {
                                                                                   throw new Error('Server responded with status: ' + response.status);
                                                                               }
                                                                               return response.json();
                                                                           })
                                                                           .then(data => {
                                                                               if (data.success) {
                                                                                   // Show success message
                                                                                   resendMessage.style.display = 'block';
                                                                                   document.getElementById('otpInput').value = '';
                                                                                   document.getElementById('otpInput').focus();

                                                                                   // Hide error if any
                                                                                   document.getElementById('otpError').style.display = 'none';

                                                                                   // Hide success message after 3 seconds
                                                                                   setTimeout(() => {
                                                                                       resendMessage.style.display = 'none';
                                                                                   }, 3000);

                                                                                   // Restore button after delay
                                                                                   setTimeout(() => {
                                                                                       resendBtn.innerHTML = originalText;
                                                                                       resendBtn.disabled = false;
                                                                                   }, 30000); // 30 second cooldown

                                                                               } else {
                                                                                   // Show error
                                                                                   document.getElementById('otpError').textContent = data.message || 'Failed to resend code. Please try again.';
                                                                                   document.getElementById('otpError').style.display = 'block';

                                                                                   // Restore button
                                                                                   resendBtn.innerHTML = originalText;
                                                                                   resendBtn.disabled = false;
                                                                               }
                                                                           })
                                                                           .catch(error => {
                                                                               console.error('Error:', error);
                                                                               document.getElementById('otpError').textContent = 'An error occurred. Please try again.';
                                                                               document.getElementById('otpError').style.display = 'block';

                                                                               // Restore button
                                                                               resendBtn.innerHTML = originalText;
                                                                               resendBtn.disabled = false;
                                                                           });
                                                               }

// Helper function to get context path
                                                               const getContextPath = () => {
                                                                   const path = '${pageContext.request.contextPath}';
                                                                   return path || '';
                                                               };

                                                               function showLoading(show) {
                                                                   const loadingDiv = document.getElementById('loading-icon-bx');
                                                                   if (loadingDiv) {
                                                                       loadingDiv.style.display = show ? 'block' : 'none';
                                                                   }
                                                               }

                                                               function showAlert(message, type = 'info') {
                                                                   // Create alert div
                                                                   const alertDiv = document.createElement('div');
                                                                   alertDiv.className = `alert alert-${type} alert-dismissible fade show`;
                                                                   alertDiv.style.cssText = 'position: fixed; top: 20px; right: 20px; z-index: 9999; min-width: 300px;';

                                                                   // Set icon based on type
                                                                   let icon = 'fa-info-circle';
                                                                   if (type === 'success')
                                                                       icon = 'fa-check-circle';
                                                                   else if (type === 'warning')
                                                                       icon = 'fa-exclamation-triangle';
                                                                   else if (type === 'error' || type === 'danger')
                                                                       icon = 'fa-times-circle';

                                                                   alertDiv.innerHTML = `
                    <i class="fa \${icon}"></i> \${message}
                    <button type="button" class="close" data-dismiss="alert" aria-label="Close">
                        <span aria-hidden="true">&times;</span>
                    </button>
                `;

                                                                   document.body.appendChild(alertDiv);

                                                                   // Auto-dismiss after 5 seconds
                                                                   setTimeout(() => {
                                                                       alertDiv.remove();
                                                                   }, 5000);
                                                               }

                                                               // Initialize on page load
                                                               document.addEventListener('DOMContentLoaded', function () {
                                                                   console.log('Page loaded - initializing booking form');

                                                                   // Check if form exists
                                                                   const bookingForm = document.getElementById('bookingForm');
                                                                   if (!bookingForm) {
                                                                       console.error('Booking form not found!');
                                                                       return;
                                                                   }

                                                                   console.log('Booking form found');

                                                                   // Add form submit listener
                                                                   bookingForm.addEventListener('submit', function (e) {
                                                                       e.preventDefault();
                                                                       console.log('Form submitted - starting validation');

                                                                       // Validate form
                                                                       if (!validateBookingForm()) {
                                                                           console.log('Validation failed');
                                                                           return;
                                                                       }

                                                                       console.log('Validation passed - checking login status');
                                                                       // Check if user is logged in
                                                                       checkLoginAndProceed();
                                                                   });

                                                                   // Check hidden inputs
                                                                   const roomTypeIdInput = document.querySelector('input[name="roomTypeId"]');
                                                                   const basePriceInput = document.querySelector('input[name="basePrice"]');

                                                                   console.log('Hidden inputs check:');
                                                                   console.log('roomTypeId input:', roomTypeIdInput);
                                                                   console.log('roomTypeId value:', roomTypeIdInput ? roomTypeIdInput.value : 'NOT FOUND');
                                                                   console.log('basePrice input:', basePriceInput);
                                                                   console.log('basePrice value:', basePriceInput ? basePriceInput.value : 'NOT FOUND');

                                                                   updateTotalPrice();
                                                                   updateGuestsDisplay();

                                                                   // Set today as minimum date for check-in
                                                                   const today = new Date().toISOString().split('T')[0];
                                                                   const checkinInput = document.querySelector('input[name="checkinDate"]');
                                                                   if (checkinInput) {
                                                                       checkinInput.setAttribute('min', today);
                                                                   }

                                                                   // Check if user is logged in and pre-fill form
                                                                   checkUserLoginStatus();

                                                                   // Add listeners for real-time validation
                                                                   addFormValidationListeners();
                                                               });

                                                               function checkUserLoginStatus() {
                                                                   const contextPath = window.location.pathname.substring(0, window.location.pathname.indexOf('/', 1));
                                                                   const url = contextPath + '/BookingServlet?action=checkLogin';

                                                                   fetch(url)
                                                                           .then(response => {
                                                                               if (!response.ok) {
                                                                                   throw new Error('Server responded with status: ' + response.status);
                                                                               }
                                                                               return response.json();
                                                                           })
                                                                           .then(data => {
                                                                               if (data.isLoggedIn && data.user) {
                                                                                   // Pre-fill form with user data
                                                                                   updateFormWithUserData(data.user);

                                                                                   // Show a welcome message
                                                                                   const welcomeDiv = document.createElement('div');
                                                                                   welcomeDiv.className = 'alert alert-info mb-3';
                                                                                   welcomeDiv.innerHTML = '<i class="fa fa-user"></i> Booking as <strong>' + data.user.fullName + '</strong>';

                                                                                   const contactSection = document.querySelector('h4').parentElement;
                                                                                   if (contactSection) {
                                                                                       contactSection.insertBefore(welcomeDiv, contactSection.firstChild);
                                                                                   }
                                                                               }
                                                                           })
                                                                           .catch(error => {
                                                                               console.error('Error checking login status:', error);
                                                                           });
                                                               }

                                                               function addFormValidationListeners() {
                                                                   // Email validation on blur
                                                                   const emailInput = document.querySelector('input[name="email"]');
                                                                   emailInput.addEventListener('blur', function () {
                                                                       const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
                                                                       if (this.value && !emailRegex.test(this.value)) {
                                                                           this.classList.add('is-invalid');
                                                                           showFieldError(this, 'Please enter a valid email address');
                                                                       } else {
                                                                           this.classList.remove('is-invalid');
                                                                           hideFieldError(this);
                                                                       }
                                                                   });

                                                                   // Phone validation on blur
                                                                   const phoneInput = document.querySelector('input[name="phone"]');
                                                                   phoneInput.addEventListener('blur', function () {
                                                                       const phoneRegex = /^(0|84|\+84)?[3456789]\d{8}$/;
                                                                       const cleanPhone = this.value.replace(/\s/g, '');
                                                                       if (this.value && !phoneRegex.test(cleanPhone)) {
                                                                           this.classList.add('is-invalid');
                                                                           showFieldError(this, 'Please enter a valid phone number');
                                                                       } else {
                                                                           this.classList.remove('is-invalid');
                                                                           hideFieldError(this);
                                                                       }
                                                                   });

                                                                   // Clear validation on input
                                                                   document.querySelectorAll('input, select, textarea').forEach(field => {
                                                                       field.addEventListener('input', function () {
                                                                           this.classList.remove('is-invalid');
                                                                           hideFieldError(this);
                                                                       });
                                                                   });
                                                               }

                                                               function showFieldError(field, message) {
                                                                   let errorDiv = field.nextElementSibling;
                                                                   if (!errorDiv || !errorDiv.classList.contains('invalid-feedback')) {
                                                                       errorDiv = document.createElement('div');
                                                                       errorDiv.className = 'invalid-feedback';
                                                                       field.parentNode.insertBefore(errorDiv, field.nextSibling);
                                                                   }
                                                                   errorDiv.textContent = message;
                                                                   errorDiv.style.display = 'block';
                                                               }

                                                               function hideFieldError(field) {
                                                                   const errorDiv = field.nextElementSibling;
                                                                   if (errorDiv && errorDiv.classList.contains('invalid-feedback')) {
                                                                       errorDiv.style.display = 'none';
                                                                   }
                                                               }
        </script>
    </body>
</html>