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

            /* Enhanced Services Container with Scrollable List */
#servicesContainer {
    max-height: 400px; /* Chiều cao tối đa cho container */
    overflow-y: auto; /* Thêm thanh cuộn dọc */
    padding-right: 10px; /* Tạo khoảng cách cho thanh cuộn */
    margin-top: 15px;
}

/* Custom Scrollbar Styling for Services Container */
#servicesContainer::-webkit-scrollbar {
    width: 8px;
}

#servicesContainer::-webkit-scrollbar-track {
    background: #f1f1f1;
    border-radius: 10px;
}

#servicesContainer::-webkit-scrollbar-thumb {
    background: #ff6b6b;
    border-radius: 10px;
    transition: background 0.3s;
}

#servicesContainer::-webkit-scrollbar-thumb:hover {
    background: #e85555;
}

/* Firefox scrollbar styling */
#servicesContainer {
    scrollbar-width: thin;
    scrollbar-color: #ff6b6b #f1f1f1;
}

/* Improve service item spacing within scrollable area */
.service-item {
    border: 1px solid #eee;
    padding: 15px;
    border-radius: 8px;
    margin-bottom: 12px; /* Tăng khoảng cách giữa các items */
    cursor: pointer;
    transition: all 0.3s;
    display: flex;
    justify-content: space-between;
    align-items: center;
    background: white;
}

.service-item:last-child {
    margin-bottom: 0; /* Bỏ margin cho item cuối cùng */
}

.service-item:hover {
    border-color: #ff6b6b;
    background: #fff5f5;
    transform: translateY(-2px);
    box-shadow: 0 4px 12px rgba(255, 107, 107, 0.15);
}

.service-item.selected {
    border-color: #ff6b6b;
    background: #fff5f5;
    box-shadow: 0 2px 8px rgba(255, 107, 107, 0.2);
}

/* Enhanced Services Section Header */
.services-section {
    background: #f8f9fa;
    padding: 25px;
    border-radius: 10px;
    margin-bottom: 25px;
    max-height: 600px; /* Giới hạn chiều cao tổng thể */
    display: flex;
    flex-direction: column;
}

.services-header {
    display: flex;
    align-items: center;
    margin-bottom: 20px;
    padding-bottom: 15px;
    border-bottom: 2px solid #e0e0e0;
    flex-shrink: 0; /* Không cho header co lại */
}

.service-categories {
    display: flex;
    gap: 10px;
    margin-bottom: 15px;
    flex-wrap: wrap;
    flex-shrink: 0; /* Không cho categories co lại */
}

/* Loading state for services */
.services-loading {
    text-align: center;
    padding: 40px 20px;
    color: #666;
}

.services-loading i {
    font-size: 48px;
    color: #ff6b6b;
    margin-bottom: 15px;
    animation: spin 1s linear infinite;
}

@keyframes spin {
    0% { transform: rotate(0deg); }
    100% { transform: rotate(360deg); }
}

/* Empty state for filtered services */
.services-empty {
    text-align: center;
    padding: 40px 20px;
    color: #999;
}

.services-empty i {
    font-size: 48px;
    color: #ddd;
    margin-bottom: 15px;
}

/* Responsive adjustments for mobile */
@media (max-width: 768px) {
    #servicesContainer {
        max-height: 300px; /* Giảm chiều cao trên mobile */
        padding-right: 5px;
    }
    
    .service-item {
        padding: 12px;
        margin-bottom: 10px;
    }
    
    .service-categories {
        gap: 8px;
    }
    
    .category-tab {
        padding: 6px 12px;
        font-size: 13px;
    }
    
    .services-section {
        padding: 20px;
        max-height: 500px;
    }
}

/* Fade effect for better visual transition */
.service-item {
    opacity: 1;
    transition: all 0.3s ease, opacity 0.2s ease;
}

.service-item.filtering {
    opacity: 0.3;
}

/* Highlight effect when services are filtered */
.services-filtered #servicesContainer {
    border: 2px solid #ff6b6b;
    border-radius: 8px;
    animation: highlight 0.5s ease-in-out;
}

@keyframes highlight {
    0% { border-color: #ff6b6b; }
    50% { border-color: #ff9999; }
    100% { border-color: #ff6b6b; }
}
            .category-tab {
                padding: 8px 16px;
                border: 1px solid #ddd;
                border-radius: 20px;
                background: white;
                cursor: pointer;
                transition: all 0.3s;
                font-size: 14px;
            }

            .category-tab:hover,
            .category-tab.active {
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
                background: white;
            }

            .service-item:hover {
                border-color: #ff6b6b;
                background: #fff5f5;
                transform: translateY(-2px);
                box-shadow: 0 4px 12px rgba(255, 107, 107, 0.15);
            }

            .service-item.selected {
                border-color: #ff6b6b;
                background: #fff5f5;
            }

            .service-item input[type="checkbox"] {
                margin-right: 15px;
                width: 18px;
                height: 18px;
                cursor: pointer;
            }

            .service-info {
                flex: 1;
                padding-right: 15px;
            }

            .service-info strong {
                display: block;
                color: #333;
                font-size: 16px;
                margin-bottom: 5px;
            }

            .service-info .category-badge {
                display: inline-block;
                background: #e8e8e8;
                color: #666;
                padding: 3px 10px;
                border-radius: 12px;
                font-size: 11px;
                margin-bottom: 5px;
            }

            .service-price {
                color: #ff6b6b;
                font-weight: 600;
                font-size: 18px;
                white-space: nowrap;
            }

            .selected-services-count {
                background: #ff6b6b;
                color: white;
                padding: 3px 12px;
                border-radius: 15px;
                font-size: 12px;
                margin-left: 10px;
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

            .price-row.service-row {
                color: #ff6b6b;
                font-size: 14px;
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

            /* Icon styles for services */
            .service-icon {
                margin-right: 8px;
                color: #ff6b6b;
            }
            /* Enhanced Booking Summary with proper header spacing */
.booking-summary {
    background: #f8f9fa;
    padding: 25px;
    border-radius: 10px;
    position: sticky;
    top: 120px; /* Tăng từ 20px lên 120px để tránh header */
    max-height: calc(100vh - 140px); /* Giới hạn chiều cao để không vượt quá viewport */
    overflow-y: auto; /* Thêm scroll nếu nội dung quá dài */
    box-shadow: 0 4px 15px rgba(0,0,0,0.1);
    transition: all 0.3s ease;
    z-index: 100; /* Đảm bảo nó nằm trên các elements khác */
}

/* Responsive adjustments for different screen sizes */
@media (max-width: 1200px) {
    .booking-summary {
        top: 100px; /* Giảm một chút cho màn hình nhỏ hơn */
        max-height: calc(100vh - 120px);
    }
}

@media (max-width: 992px) {
    .booking-summary {
        position: relative; /* Bỏ sticky trên tablet */
        top: auto;
        max-height: none;
        margin-top: 30px;
    }
}

@media (max-width: 768px) {
    .booking-summary {
        position: relative;
        top: auto;
        max-height: none;
        margin-top: 20px;
        padding: 20px;
    }
}

/* Enhanced visual effects for booking summary */
.booking-summary:hover {
    box-shadow: 0 8px 25px rgba(0,0,0,0.15);
    transform: translateY(-2px);
}

/* Smooth scrolling for booking summary content */
.booking-summary::-webkit-scrollbar {
    width: 6px;
}

.booking-summary::-webkit-scrollbar-track {
    background: #f1f1f1;
    border-radius: 3px;
}

.booking-summary::-webkit-scrollbar-thumb {
    background: #ff6b6b;
    border-radius: 3px;
}

.booking-summary::-webkit-scrollbar-thumb:hover {
    background: #e85555;
}

/* Firefox scrollbar */
.booking-summary {
    scrollbar-width: thin;
    scrollbar-color: #ff6b6b #f1f1f1;
}

/* Enhanced spacing and typography within booking summary */
.booking-summary h4 {
    margin-bottom: 20px;
    color: #333;
    font-size: 22px;
    font-weight: 600;
    border-bottom: 2px solid #ff6b6b;
    padding-bottom: 10px;
}

.booking-summary .price-breakdown {
    border-top: 1px solid #eee;
    padding-top: 15px;
    margin-top: 15px;
}

.booking-summary .price-row {
    display: flex;
    justify-content: space-between;
    margin-bottom: 12px;
    color: #666;
    font-size: 15px;
}

.booking-summary .price-row.service-row {
    color: #ff6b6b;
    font-size: 14px;
    padding-left: 15px;
}

.booking-summary .total-price {
    display: flex;
    justify-content: space-between;
    font-size: 24px;
    font-weight: 700;
    color: #333;
    margin-top: 20px;
    padding-top: 20px;
    border-top: 3px solid #ff6b6b;
    background: linear-gradient(135deg, #fff5f5 0%, #ffffff 100%);
    padding: 20px;
    border-radius: 10px;
    margin: 20px -5px 0 -5px;
}

/* Enhanced booking button */
.book-now-btn {
    width: 100%;
    padding: 18px;
    background: linear-gradient(135deg, #ff6b6b 0%, #e85555 100%);
    color: white;
    border: none;
    border-radius: 8px;
    font-size: 18px;
    font-weight: 600;
    cursor: pointer;
    transition: all 0.3s ease;
    margin-top: 25px;
    text-transform: uppercase;
    letter-spacing: 1px;
    box-shadow: 0 4px 15px rgba(255, 107, 107, 0.3);
}

.book-now-btn:hover {
    background: linear-gradient(135deg, #e85555 0%, #d94444 100%);
    transform: translateY(-2px);
    box-shadow: 0 6px 20px rgba(255, 107, 107, 0.4);
}

.book-now-btn:active {
    transform: translateY(0);
    box-shadow: 0 2px 10px rgba(255, 107, 107, 0.3);
}

.book-now-btn:disabled {
    background: #ccc !important;
    cursor: not-allowed !important;
    transform: none !important;
    box-shadow: none !important;
}

/* Security notice styling */
.booking-summary .text-center.mt-3 {
    margin-top: 20px !important;
    padding: 15px;
    background: #f8f9fa;
    border-radius: 8px;
    border: 1px solid #e9ecef;
}

.booking-summary .text-center.mt-3 small {
    color: #6c757d;
    font-size: 13px;
    line-height: 1.6;
}

/* Terms checkbox styling */
.booking-summary .form-check {
    margin: 20px 0;
    padding: 15px;
    background: white;
    border-radius: 8px;
    border: 1px solid #dee2e6;
}

.booking-summary .form-check-input {
    margin-right: 10px;
    transform: scale(1.2);
}

.booking-summary .form-check-label {
    font-size: 14px;
    color: #495057;
    cursor: pointer;
}

.booking-summary .form-check-label a {
    color: #ff6b6b;
    text-decoration: none;
}

.booking-summary .form-check-label a:hover {
    text-decoration: underline;
}

/* Animation for price updates */
.booking-summary .price-row,
.booking-summary .total-price {
    transition: all 0.3s ease;
}

.booking-summary .price-row.updated {
    background: #fff5f5;
    padding: 5px 10px;
    border-radius: 5px;
    animation: priceUpdate 0.6s ease;
}

@keyframes priceUpdate {
    0% { background: #ff6b6b; color: white; }
    100% { background: #fff5f5; color: inherit; }
}

/* Loading state for booking button */
.book-now-btn .fa-spinner {
    margin-right: 8px;
}

/* Guest display styling */
.booking-summary .mb-3.pb-3.border-bottom p {
    color: #6c757d;
    font-size: 14px;
    margin-bottom: 5px;
}

.booking-summary .mb-3.pb-3.border-bottom h5 {
    color: #333;
    font-size: 18px;
    font-weight: 600;
    margin-bottom: 8px;
}
    .payment-option-card {
        border: 2px solid #dee2e6;
        border-radius: 10px;
        padding: 20px;
        margin-bottom: 15px;
        cursor: pointer;
        transition: all 0.3s ease;
        background: white;
    }
    
    .payment-option-card:hover {
        border-color: #007bff;
        box-shadow: 0 0 10px rgba(0,123,255,0.2);
    }
    
    .payment-option-card.selected {
        border-color: #28a745;
        background: #f0f9ff;
        box-shadow: 0 0 15px rgba(40,167,69,0.3);
    }
    
    .payment-option-header {
        display: flex;
        align-items: center;
        margin-bottom: 10px;
    }
    
    .payment-option-radio {
        width: 20px;
        height: 20px;
        margin-right: 15px;
    }
    
    .payment-option-title {
        font-size: 1.2rem;
        font-weight: bold;
        margin: 0;
    }
    
    .payment-option-amount {
        font-size: 1.5rem;
        color: #28a745;
        font-weight: bold;
        margin: 10px 0;
    }
    
    .payment-option-description {
        color: #6c757d;
        font-size: 0.9rem;
        margin-bottom: 0;
    }
    
    .payment-option-badge {
        display: inline-block;
        padding: 4px 12px;
        border-radius: 20px;
        font-size: 0.85rem;
        font-weight: 500;
        margin-left: 10px;
    }
    
    .badge-recommended {
        background: #28a745;
        color: white;
    }
    
    .badge-info {
        background: #17a2b8;
        color: white;
    }
    
    .payment-breakdown {
        background: #f8f9fa;
        border-radius: 8px;
        padding: 15px;
        margin-top: 20px;
    }
    
    .breakdown-row {
        display: flex;
        justify-content: space-between;
        padding: 8px 0;
        border-bottom: 1px solid #e9ecef;
    }
    
    .breakdown-row:last-child {
        border-bottom: none;
        font-weight: bold;
        font-size: 1.1rem;
        color: #28a745;
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
                                         <div class="room-availability-section mb-4">
    <div class="availability-status" id="availabilityStatus">
        <div class="availability-placeholder">
            <div class="text-center p-4">
                <i class="fa fa-calendar-check-o" style="font-size: 48px; color: #ddd;"></i>
                <h5 class="mt-3 mb-2">Check Room Availability</h5>
                <p class="text-muted mb-0">Please select your check-in and check-out dates to see available rooms</p>
            </div>
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

                                       <!-- Enhanced Additional Services Section -->
<div class="services-section">
    <div class="services-header">
        <h4>
            <i class="fa fa-concierge-bell service-icon"></i>
            Additional Services
        </h4>
        <span class="badge">Optional</span>
        <span class="selected-services-count" id="selectedServicesCount" style="display: none;">0 selected</span>
    </div>
    
    <!-- Service Categories -->
    <div class="service-categories">
        <div class="category-tab active" onclick="filterServices('all'); scrollToServicesTop();">All Services</div>
        <div class="category-tab" onclick="filterServices('TRANSPORT'); scrollToServicesTop();">Transportation</div>
        <div class="category-tab" onclick="filterServices('DINING'); scrollToServicesTop();">Dining</div>
        <div class="category-tab" onclick="filterServices('SPA'); scrollToServicesTop();">Spa & Wellness</div>
        <div class="category-tab" onclick="filterServices('SPECIAL'); scrollToServicesTop();">Special Services</div>
    </div>
    
    <!-- Services Container with Scroll -->
    <div id="servicesContainer">
        <% 
        String previousCategory = "";
        for(Service service : services) { 
            // Determine category from service name/description
            String category = "OTHER";
            String serviceName = service.getName().toLowerCase();
            String serviceDesc = service.getDescription() != null ? service.getDescription().toLowerCase() : "";
            
            if (serviceName.contains("airport") || serviceName.contains("shuttle") || 
                serviceName.contains("tour") || serviceName.contains("car")) {
                category = "TRANSPORT";
            } else if (serviceName.contains("breakfast") || serviceName.contains("dinner") || 
                      serviceName.contains("room service") || serviceName.contains("mini bar")) {
                category = "DINING";
            } else if (serviceName.contains("spa") || serviceName.contains("massage") || 
                      serviceName.contains("yoga")) {
                category = "SPA";
            } else if (serviceName.contains("flower") || serviceName.contains("birthday") || 
                      serviceName.contains("honeymoon") || serviceName.contains("laundry")) {
                category = "SPECIAL";
            }
            
            // Icon based on category
            String icon = "fa-concierge-bell";
            switch(category) {
                case "TRANSPORT": icon = "fa-car"; break;
                case "DINING": icon = "fa-utensils"; break;
                case "SPA": icon = "fa-spa"; break;
                case "SPECIAL": icon = "fa-gift"; break;
            }
        %>
        <div class="service-item" data-category="<%= category %>" tabindex="0">
            <label style="display: flex; align-items: center; width: 100%; cursor: pointer; margin: 0;">
                <input type="checkbox" name="services" value="<%= service.getId() %>" 
                       data-price="<%= service.getPrice() %>" 
                       onchange="toggleServiceSelection(this);">
                <div class="service-info">
                    <strong>
                        <i class="fa <%= icon %> service-icon"></i>
                        <%= service.getName() %>
                    </strong>
                    <div class="category-badge"><%= category %></div>
                    <div class="text-muted small"><%= service.getDescription() %></div>
                </div>
                <div class="service-price">
                    <%= df.format(service.getPrice()) %>₫
                </div>
            </label>
        </div>
        <% } %>
    </div>
    
    <!-- Services scroll hint -->
    <div class="text-center mt-2">
        <small class="text-muted">
            <i class="fa fa-mouse-pointer"></i> Click categories to filter • <i class="fa fa-arrows-v"></i> Scroll to see more services
        </small>
    </div>
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

                     
            <!-- Content END-->

            <!-- Footer ==== -->
     
            <!-- Footer END ==== -->
            <button class="back-to-top fa fa-chevron-up" ></button>
           
        </div>
        <jsp:include page="footer.jsp" />
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
     

        <!-- Custom JavaScript for booking functionality -->
   <script>
         // Complete Optimized JavaScript for Room Booking Page

const basePrice = <%= roomTypes.getBasePrice() %>;
let nights = 1;
let adults = 2;
let children = 0;

// ============================================================================
// IMAGE GALLERY FUNCTIONS
// ============================================================================

function changeMainImage(img) {
    document.getElementById('mainImage').src = img.src;
    document.querySelectorAll('.room-thumbnails img').forEach(function(thumb) {
        thumb.classList.remove('active');
    });
    img.classList.add('active');
}

// ============================================================================
// DATE FUNCTIONS
// ============================================================================

function updateCheckoutMin() {
    const checkinDate = document.querySelector('input[name="checkinDate"]').value;
    const checkoutInput = document.querySelector('input[name="checkoutDate"]');

    if (checkinDate) {
        const checkin = new Date(checkinDate);
        checkin.setDate(checkin.getDate() + 1);
        const minCheckout = checkin.toISOString().split('T')[0];
        checkoutInput.setAttribute('min', minCheckout);

        if (checkoutInput.value && checkoutInput.value < minCheckout) {
            checkoutInput.value = minCheckout;
        }
        
        if (!checkoutInput.value) {
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
        
        if (checkout <= checkin) {
            showDateValidationError();
            return;
        }
        
        nights = Math.ceil((checkout - checkin) / (1000 * 60 * 60 * 24));
        
        document.getElementById('nightsDisplay').textContent = nights;
        document.getElementById('nightsText').textContent = nights;
        
        updateTotalPrice();
        checkRoomAvailability(checkinDate, checkoutDate);
    } else {
        showAvailabilityPlaceholder();
        enableBookingButton();
    }
}

function calculateNightsBetweenDates(checkinDate, checkoutDate) {
    const checkin = new Date(checkinDate);
    const checkout = new Date(checkoutDate);
    const timeDiff = checkout.getTime() - checkin.getTime();
    return Math.ceil(timeDiff / (1000 * 3600 * 24));
}

function formatDateForDisplay(dateString) {
    const date = new Date(dateString);
    const options = { 
        weekday: 'short', 
        year: 'numeric', 
        month: 'short', 
        day: 'numeric' 
    };
    return date.toLocaleDateString('en-US', options);
}

// ============================================================================
// ROOM AVAILABILITY FUNCTIONS
// ============================================================================

function showAvailabilityPlaceholder() {
    const statusDiv = document.getElementById('availabilityStatus');
    if (!statusDiv) return;

    statusDiv.className = 'availability-status';
    statusDiv.innerHTML = 
        '<div class="availability-placeholder">' +
            '<div class="text-center p-4">' +
                '<i class="fa fa-calendar-check-o" style="font-size: 48px; color: #ddd;"></i>' +
                '<h5 class="mt-3 mb-2">Check Room Availability</h5>' +
                '<p class="text-muted mb-0">Please select your check-in and check-out dates to see available rooms</p>' +
            '</div>' +
        '</div>';
}

function showAvailabilityLoading() {
    const statusDiv = document.getElementById('availabilityStatus');
    if (!statusDiv) return;

    statusDiv.innerHTML = 
        '<div class="availability-loading">' +
            '<i class="fa fa-spinner fa-spin" style="font-size: 48px; color: #ff6b6b;"></i>' +
            '<p class="mt-3 mb-0">Checking room availability...</p>' +
            '<small class="text-muted">Please wait while we search for available rooms</small>' +
        '</div>';
}

function showAvailabilityError() {
    const statusDiv = document.getElementById('availabilityStatus');
    if (!statusDiv) return;

    statusDiv.innerHTML = 
        '<div class="availability-error text-center p-4">' +
            '<i class="fa fa-exclamation-triangle" style="font-size: 48px; color: #dc3545;"></i>' +
            '<h5 class="mt-3 mb-2 text-danger">Unable to Check Availability</h5>' +
            '<p class="text-muted mb-3">There was an error checking room availability. Please try again.</p>' +
            '<button type="button" class="btn btn-outline-primary btn-sm" onclick="retryAvailabilityCheck()">' +
                '<i class="fa fa-refresh"></i> Try Again' +
            '</button>' +
        '</div>';
}

function showDateValidationError() {
    const statusDiv = document.getElementById('availabilityStatus');
    if (!statusDiv) return;

    statusDiv.className = 'availability-status';
    statusDiv.innerHTML = 
        '<div class="availability-error text-center p-4">' +
            '<i class="fa fa-exclamation-triangle" style="font-size: 48px; color: #ffc107;"></i>' +
            '<h5 class="mt-3 mb-2 text-warning">Invalid Date Selection</h5>' +
            '<p class="text-muted mb-0">Check-out date must be after check-in date. Please select valid dates.</p>' +
        '</div>';
    disableBookingButton();
}

function retryAvailabilityCheck() {
    const checkinDate = document.querySelector('input[name="checkinDate"]').value;
    const checkoutDate = document.querySelector('input[name="checkoutDate"]').value;
    
    if (checkinDate && checkoutDate) {
        checkRoomAvailability(checkinDate, checkoutDate);
    } else {
        showAvailabilityPlaceholder();
    }
}

function checkRoomAvailability(checkinDate, checkoutDate) {
    const roomTypeId = document.querySelector('input[name="roomTypeId"]').value;
    const contextPath = getContextPath();
    const statusDiv = document.getElementById('availabilityStatus');
    
    if (!statusDiv) {
        console.error('Availability status div not found');
        return;
    }

    showAvailabilityLoading();
    statusDiv.classList.add('checking');

    fetch(contextPath + '/CheckRoomAvailability?roomTypeId=' + roomTypeId +
            '&checkIn=' + checkinDate + '&checkOut=' + checkoutDate)
    .then(function(response) {
        if (!response.ok) {
            throw new Error('Network response was not ok');
        }
        return response.json();
    })
    .then(function(data) {
        statusDiv.classList.remove('checking');
        updateAvailabilityStatus(data);
    })
    .catch(function(error) {
        console.error('Error checking availability:', error);
        statusDiv.classList.remove('checking');
        showAvailabilityError();
    });
}

function updateAvailabilityStatus(data) {
    const statusDiv = document.getElementById('availabilityStatus');
    if (!statusDiv) return;

    const checkinDate = document.querySelector('input[name="checkinDate"]').value;
    const checkoutDate = document.querySelector('input[name="checkoutDate"]').value;
    const roomTypeName = '<%= roomTypes.getName() %>';

    if (data.available) {
        statusDiv.className = 'availability-status available';
        
        const availableCount = data.availableCount || 'Multiple';
        const nightsCount = calculateNightsBetweenDates(checkinDate, checkoutDate);
        
        statusDiv.innerHTML = 
            '<div class="text-center pt-4">' +
                '<div class="availability-badge available">' +
                    '<i class="fa fa-check-circle"></i>' +
                    '<span>Rooms Available!</span>' +
                '</div>' +
            '</div>' +
            '<div class="availability-details">' +
                '<h5><i class="fa fa-info-circle"></i> Booking Details</h5>' +
                '<div class="availability-info">' +
                    '<span>Room Type:</span>' +
                    '<span>' + roomTypeName + '</span>' +
                '</div>' +
                '<div class="availability-info">' +
                    '<span>Check-in Date:</span>' +
                    '<span>' + formatDateForDisplay(checkinDate) + '</span>' +
                '</div>' +
                '<div class="availability-info">' +
                    '<span>Check-out Date:</span>' +
                    '<span>' + formatDateForDisplay(checkoutDate) + '</span>' +
                '</div>' +
                '<div class="availability-info">' +
                    '<span>Duration:</span>' +
                    '<span>' + nightsCount + ' night' + (nightsCount > 1 ? 's' : '') + '</span>' +
                '</div>' +
                '<div class="availability-info">' +
                    '<span>Available Rooms:</span>' +
                    '<span class="text-success"><strong>' + availableCount + ' rooms</strong></span>' +
                '</div>' +
            '</div>' +
            '<div class="availability-message success">' +
                '<i class="fa fa-thumbs-up"></i>' +
                'Great news! We have rooms available for your selected dates. You can proceed with your booking.' +
            '</div>';

        enableBookingButton();
    } else {
        statusDiv.className = 'availability-status unavailable';
        
        statusDiv.innerHTML = 
            '<div class="text-center pt-4">' +
                '<div class="availability-badge unavailable">' +
                    '<i class="fa fa-times-circle"></i>' +
                    '<span>No Rooms Available</span>' +
                '</div>' +
            '</div>' +
            '<div class="availability-details">' +
                '<h5><i class="fa fa-exclamation-triangle"></i> Booking Information</h5>' +
                '<div class="availability-info">' +
                    '<span>Room Type:</span>' +
                    '<span>' + roomTypeName + '</span>' +
                '</div>' +
                '<div class="availability-info">' +
                    '<span>Requested Dates:</span>' +
                    '<span>' + formatDateForDisplay(checkinDate) + ' - ' + formatDateForDisplay(checkoutDate) + '</span>' +
                '</div>' +
                '<div class="availability-info">' +
                    '<span>Status:</span>' +
                    '<span class="text-danger"><strong>Fully Booked</strong></span>' +
                '</div>' +
            '</div>' +
            '<div class="availability-message error">' +
                '<i class="fa fa-calendar-times-o"></i>' +
                'Sorry, we don\'t have any ' + roomTypeName + ' rooms available for your selected dates. ' +
                'Please try different dates or consider other room types.' +
            '</div>' +
            '<div class="availability-actions">' +
                '<a href="' + getContextPath() + '/RoomListServlet" class="btn btn-primary">' +
                    '<i class="fa fa-search"></i> View Other Room Types' +
                '</a>' +
            '</div>';

        disableBookingButton();
    }
    
    setTimeout(function() {
        statusDiv.scrollIntoView({ 
            behavior: 'smooth', 
            block: 'nearest' 
        });
    }, 100);
}

function enableBookingButton() {
    const bookingBtn = document.querySelector('.book-now-btn');
    if (bookingBtn) {
        bookingBtn.disabled = false;
        bookingBtn.textContent = 'Confirm Booking';
        bookingBtn.style.backgroundColor = '#ff6b6b';
        bookingBtn.style.cursor = 'pointer';
    }
}

function disableBookingButton() {
    const bookingBtn = document.querySelector('.book-now-btn');
    if (bookingBtn) {
        bookingBtn.disabled = true;
        bookingBtn.textContent = 'No Rooms Available';
        bookingBtn.style.backgroundColor = '#ccc';
        bookingBtn.style.cursor = 'not-allowed';
    }
}

// ============================================================================
// GUEST FUNCTIONS
// ============================================================================

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

// ============================================================================
// PRICE CALCULATION FUNCTIONS
// ============================================================================

function updateTotalPrice() {
    const roomPrice = basePrice * nights;
    const tax = roomPrice * 0.1;
    let servicesTotal = 0;
    let servicesHtml = '';

    document.querySelectorAll('input[name="services"]:checked').forEach(function(checkbox) {
        const servicePrice = parseFloat(checkbox.getAttribute('data-price'));
        servicesTotal += servicePrice;

        const serviceName = checkbox.parentElement.querySelector('.service-info strong').textContent.trim();
        servicesHtml += '<div class="price-row service-row">' +
                '<span><i class="fa fa-check-circle"></i> ' + serviceName + '</span>' +
                '<span>' + formatPrice(servicePrice) + '</span>' +
                '</div>';
    });

    const total = roomPrice + tax + servicesTotal;

    document.getElementById('roomPriceDisplay').textContent = formatPrice(roomPrice);
    document.getElementById('taxDisplay').textContent = formatPrice(tax);
    document.getElementById('servicesDisplay').innerHTML = servicesHtml;
    document.getElementById('totalPriceDisplay').textContent = formatPrice(total);
}

function formatPrice(price) {
    return new Intl.NumberFormat('vi-VN').format(price) + '₫';
}

// ============================================================================
// SERVICES FUNCTIONS
// ============================================================================

function filterServices(category) {
    document.querySelectorAll('.category-tab').forEach(function(tab) {
        tab.classList.remove('active');
    });
    event.target.classList.add('active');
    
    const servicesContainer = document.getElementById('servicesContainer');
    servicesContainer.classList.add('services-filtered');
    
    const serviceItems = document.querySelectorAll('.service-item');
    let visibleCount = 0;
    
    serviceItems.forEach(function(item) {
        item.classList.add('filtering');
    });
    
    setTimeout(function() {
        serviceItems.forEach(function(item, index) {
            setTimeout(function() {
                item.classList.remove('filtering');
                
                if (category === 'all' || item.getAttribute('data-category') === category) {
                    item.style.display = 'flex';
                    visibleCount++;
                } else {
                    item.style.display = 'none';
                }
            }, index * 20);
        });
        
        setTimeout(function() {
            showEmptyStateIfNeeded(category, visibleCount);
            servicesContainer.classList.remove('services-filtered');
        }, serviceItems.length * 20 + 100);
    }, 100);
}

function showEmptyStateIfNeeded(category, visibleCount) {
    const servicesContainer = document.getElementById('servicesContainer');
    let emptyStateDiv = document.getElementById('servicesEmptyState');
    
    if (visibleCount === 0) {
        if (!emptyStateDiv) {
            emptyStateDiv = document.createElement('div');
            emptyStateDiv.id = 'servicesEmptyState';
            emptyStateDiv.className = 'services-empty';
            servicesContainer.appendChild(emptyStateDiv);
        }
        
        const categoryDisplay = category === 'all' ? 'All Categories' : category;
        emptyStateDiv.innerHTML = 
            '<i class="fa fa-search"></i>' +
            '<p>No services found in <strong>' + categoryDisplay + '</strong> category.</p>' +
            '<small class="text-muted">Try selecting a different category.</small>';
        
        emptyStateDiv.style.display = 'block';
    } else {
        if (emptyStateDiv) {
            emptyStateDiv.style.display = 'none';
        }
    }
}

function scrollToServicesTop() {
    const servicesSection = document.querySelector('.services-section');
    if (servicesSection) {
        servicesSection.scrollIntoView({ 
            behavior: 'smooth', 
            block: 'nearest' 
        });
    }
}

function toggleServiceSelection(checkbox) {
    const serviceItem = checkbox.closest('.service-item');
    
    if (checkbox.checked) {
        serviceItem.classList.add('selected');
        serviceItem.style.transform = 'scale(1.02)';
        setTimeout(function() {
            serviceItem.style.transform = 'translateY(-2px)';
        }, 150);
    } else {
        serviceItem.classList.remove('selected');
        serviceItem.style.transform = 'none';
    }
    
    updateTotalPrice();
    updateSelectedCount();
}

function updateSelectedCount() {
    const selectedCount = document.querySelectorAll('input[name="services"]:checked').length;
    const countElement = document.getElementById('selectedServicesCount');
    
    if (selectedCount > 0) {
        countElement.textContent = selectedCount + ' selected';
        countElement.style.display = 'inline-block';
    } else {
        countElement.style.display = 'none';
    }
    
    document.querySelectorAll('.service-item').forEach(function(item) {
        const checkbox = item.querySelector('input[type="checkbox"]');
        if (checkbox.checked) {
            item.classList.add('selected');
        } else {
            item.classList.remove('selected');
        }
    });
}

// ============================================================================
// FORM VALIDATION FUNCTIONS
// ============================================================================

function validateBookingForm() {
    const termsCheck = document.getElementById('termsCheck');
    if (!termsCheck || !termsCheck.checked) {
        showAlert('Please accept the terms and conditions', 'warning');
        return false;
    }

    const bookingBtn = document.querySelector('.book-now-btn');
    if (bookingBtn && bookingBtn.disabled) {
        showAlert('No rooms available for selected dates', 'warning');
        return false;
    }

    const checkinDate = document.querySelector('input[name="checkinDate"]').value;
    const checkoutDate = document.querySelector('input[name="checkoutDate"]').value;
    const fullName = document.querySelector('input[name="fullName"]').value.trim();
    const email = document.querySelector('input[name="email"]').value.trim();
    const phone = document.querySelector('input[name="phone"]').value.trim();

    if (!checkinDate || !checkoutDate) {
        showAlert('Please select both check-in and check-out dates', 'warning');
        return false;
    }

    if (!fullName || !email || !phone) {
        showAlert('Please fill in all required contact information', 'warning');
        return false;
    }

    const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
    if (!emailRegex.test(email)) {
        showAlert('Please enter a valid email address', 'warning');
        return false;
    }

    const phoneRegex = /^(0|84|\+84)?[3456789]\d{8}$/;
    if (!phoneRegex.test(phone.replace(/\s/g, ''))) {
        showAlert('Please enter a valid phone number', 'warning');
        return false;
    }

    return true;
}

function addFormValidationListeners() {
    const emailInput = document.querySelector('input[name="email"]');
    const phoneInput = document.querySelector('input[name="phone"]');

    if (emailInput) {
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
    }

    if (phoneInput) {
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
    }

    document.querySelectorAll('input, select, textarea').forEach(function(field) {
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

// ============================================================================
// BOOKING SUBMISSION FUNCTIONS
// ============================================================================

function checkLoginAndProceed() {
    showLoading(true);
    const url = getContextPath() + '/BookingServlet?action=checkLogin';

    fetch(url)
    .then(function(response) {
        if (!response.ok) {
            throw new Error('Server responded with status: ' + response.status);
        }
        return response.json();
    })
    .then(function(data) {
        if (data.isLoggedIn) {
            updateFormWithUserData(data.user);
        }
        submitBookingForm();
    })
    .catch(function(error) {
        showLoading(false);
        console.error('Error:', error);
        showAlert('An error occurred. Please try again.', 'error');
    });
}

function updateFormWithUserData(user) {
    if (user) {
        if (user.fullName) document.querySelector('input[name="fullName"]').value = user.fullName;
        if (user.email) document.querySelector('input[name="email"]').value = user.email;
        if (user.phone) document.querySelector('input[name="phone"]').value = user.phone;
    }
}

function handleBookingButtonState(isLoading) {
    const bookingBtn = document.querySelector('.book-now-btn');
    if (!bookingBtn) return;

    if (isLoading) {
        bookingBtn.innerHTML = '<i class="fa fa-spinner fa-spin"></i> Processing...';
        bookingBtn.disabled = true;
        bookingBtn.style.background = '#ccc';
    } else {
        bookingBtn.innerHTML = 'Confirm Booking';
        bookingBtn.disabled = false;
        bookingBtn.style.background = '#ff6b6b';
    }
}

function submitBookingForm() {
    handleBookingButtonState(true);

    const form = document.getElementById('bookingForm');
    if (!form) {
        showAlert('Error: Booking form not found', 'error');
        handleBookingButtonState(false);
        return;
    }

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
        paymentMethod: form.paymentMethod.value,
        nights: nights
    };

    const selectedServices = [];
    document.querySelectorAll('input[name="services"]:checked').forEach(function(checkbox) {
        selectedServices.push(checkbox.value);
    });

    let params = new URLSearchParams();
    for (let key in formData) {
        params.append(key, formData[key]);
    }
    selectedServices.forEach(function(serviceId) {
        params.append('services', serviceId);
    });

    const url = getContextPath() + '/BookingServlet';

    fetch(url, {
        method: 'POST',
        headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
        body: params.toString()
    })
    .then(function(response) {
        return response.text().then(function(text) {
            if (!response.ok) {
                try {
                    const errorData = JSON.parse(text);
                    throw new Error(errorData.error || 'Server responded with status: ' + response.status);
                } catch (e) {
                    throw new Error('Server responded with status: ' + response.status);
                }
            }
            return JSON.parse(text);
        });
    })
    .then(function(data) {
        handleBookingButtonState(false);
        showLoading(false);

        if (data.requireOTP) {
            showOTPModal(data.email);
        } else if (data.success) {
            showAlert('Booking confirmed! Redirecting...', 'success');
            setTimeout(function() {
                const paymentMethod = document.querySelector('input[name="paymentMethod"]:checked').value;
                handleBookingSuccess(data, paymentMethod);
            }, 1000);
        } else {
            showAlert(data.error || 'Booking failed. Please try again.', 'error');
        }
    })
    .catch(function(error) {
        handleBookingButtonState(false);
        showLoading(false);
        showAlert(error.message || 'An error occurred while processing your booking. Please try again.', 'error');
    });
}

function handleBookingSuccess(data, paymentMethod) {
    if (paymentMethod === 'CASH') {
        window.location.href = 'BookingConfirmation?reservationId=' + data.reservationId;
    } else {
        window.location.href = 'PaymentGateway?reservationId=' + data.reservationId +
                '&paymentId=' + data.paymentId + '&method=' + paymentMethod;
    }
}

// ============================================================================
// OTP FUNCTIONS
// ============================================================================

function showOTPModal(maskedEmail) {
    const modalHTML = 
        '<div id="otpModal" class="modal" style="display: block; position: fixed; z-index: 1000; left: 0; top: 0; width: 100%; height: 100%; background-color: rgba(0,0,0,0.5);">' +
            '<div class="modal-content" style="background-color: #fefefe; margin: 5% auto; padding: 0; border: 1px solid #888; width: 90%; max-width: 450px; border-radius: 10px; box-shadow: 0 4px 20px rgba(0,0,0,0.3); max-height: 90vh; overflow-y: auto;">' +
                '<div style="background: #ff6b6b; color: white; padding: 20px; border-radius: 10px 10px 0 0; position: sticky; top: 0; z-index: 1;">' +
                    '<h3 style="margin: 0; text-align: center;">Email Verification Required</h3>' +
                '</div>' +
                '<div style="padding: 30px;">' +
                    '<div style="text-align: center; margin-bottom: 20px;">' +
                        '<i class="fa fa-envelope" style="font-size: 48px; color: #ff6b6b;"></i>' +
                    '</div>' +
                    '<p style="text-align: center; color: #333; margin-bottom: 10px;">We\'ve sent a verification code to</p>' +
                    '<p style="text-align: center; font-weight: bold; color: #ff6b6b; font-size: 18px; margin-bottom: 20px;">' + maskedEmail + '</p>' +
                    '<p style="text-align: center; color: #666; margin-bottom: 20px;">Please enter the 6-digit code below:</p>' +
                    '<input type="text" id="otpInput" maxlength="6" pattern="[0-9]{6}" ' +
                           'style="width: 100%; padding: 15px; font-size: 24px; text-align: center; letter-spacing: 10px; margin: 20px 0; border: 2px solid #ddd; border-radius: 5px; box-sizing: border-box;" ' +
                           'placeholder="000000" onkeyup="handleOTPInput(event)">' +
                    '<div id="otpError" style="color: #dc3545; text-align: center; margin-bottom: 20px; display: none;"></div>' +
                    '<div style="text-align: center; margin-bottom: 20px;">' +
                        '<button type="button" onclick="verifyOTP()" class="btn" style="margin-right: 10px; padding: 10px 30px; background: #ff6b6b; color: white; border: none; border-radius: 5px; font-size: 16px; cursor: pointer;">Verify Code</button>' +
                        '<button type="button" onclick="resendOTP()" class="btn btn-secondary" style="padding: 10px 30px; background: #6c757d; color: white; border: none; border-radius: 5px; font-size: 16px; cursor: pointer;">Resend Code</button>' +
                    '</div>' +
                    '<div id="resendMessage" style="text-align: center; color: #28a745; display: none; margin-bottom: 10px;"><i class="fa fa-check-circle"></i> New code sent successfully!</div>' +
                    '<p style="text-align: center; margin-top: 20px; color: #666; font-size: 14px;"><i class="fa fa-info-circle"></i> Didn\'t receive the code? Check your spam folder or click Resend Code.</p>' +
                    '<div style="text-align: center; margin-top: 30px; padding-top: 20px; border-top: 1px solid #eee;">' +
                        '<button type="button" onclick="closeOTPModal()" style="background: #f8f9fa; border: 1px solid #dee2e6; color: #6c757d; cursor: pointer; font-size: 14px; padding: 10px 30px; border-radius: 5px;"><i class="fa fa-times"></i> Cancel Booking</button>' +
                    '</div>' +
                '</div>' +
            '</div>' +
        '</div>';

    document.body.insertAdjacentHTML('beforeend', modalHTML);
    document.getElementById('otpInput').focus();

    document.getElementById('otpInput').addEventListener('input', function () {
        if (this.value.length === 6) {
            verifyOTP();
        }
    });
}

function handleOTPInput(event) {
    const input = event.target;
    input.value = input.value.replace(/[^0-9]/g, '');
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

    if (otp.length !== 6) {
        errorDiv.textContent = 'Please enter a 6-digit code';
        errorDiv.style.display = 'block';
        return;
    }

    const verifyBtn = document.querySelector('button[onclick="verifyOTP()"]');
    const originalText = verifyBtn.innerHTML;
    verifyBtn.innerHTML = '<i class="fa fa-spinner fa-spin"></i> Verifying...';
    verifyBtn.disabled = true;

    const url = getContextPath() + '/ValidateOTP';

    fetch(url, {
        method: 'POST',
        headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
        body: 'otp=' + otp
    })
    .then(function(response) {
        if (!response.ok) {
            throw new Error('Server responded with status: ' + response.status);
        }
        return response.json();
    })
    .then(function(data) {
        if (data.success) {
            errorDiv.style.display = 'none';
            verifyBtn.innerHTML = '<i class="fa fa-check"></i> Verified!';
            verifyBtn.style.background = '#28a745';

            setTimeout(function() {
                closeOTPModal();
                submitBookingForm();
            }, 1000);
        } else {
            errorDiv.textContent = data.message || 'Invalid code. Please try again.';
            errorDiv.style.display = 'block';
            otpInput.value = '';
            otpInput.focus();
            verifyBtn.innerHTML = originalText;
            verifyBtn.disabled = false;
        }
    })
    .catch(function(error) {
        console.error('Error:', error);
        errorDiv.textContent = 'An error occurred. Please try again.';
        errorDiv.style.display = 'block';
        verifyBtn.innerHTML = originalText;
        verifyBtn.disabled = false;
    });
}

function resendOTP() {
    const resendBtn = document.querySelector('button[onclick="resendOTP()"]');
    const originalText = resendBtn.innerHTML;
    const resendMessage = document.getElementById('resendMessage');

    resendBtn.innerHTML = '<i class="fa fa-spinner fa-spin"></i> Sending...';
    resendBtn.disabled = true;

    const url = getContextPath() + '/ResendOTP';

    fetch(url, { method: 'POST' })
    .then(function(response) {
        if (!response.ok) {
            throw new Error('Server responded with status: ' + response.status);
        }
        return response.json();
    })
    .then(function(data) {
        if (data.success) {
            resendMessage.style.display = 'block';
            document.getElementById('otpInput').value = '';
            document.getElementById('otpInput').focus();
            document.getElementById('otpError').style.display = 'none';

            setTimeout(function() {
                resendMessage.style.display = 'none';
            }, 3000);

            setTimeout(function() {
                resendBtn.innerHTML = originalText;
                resendBtn.disabled = false;
            }, 10000);
        } else {
            document.getElementById('otpError').textContent = data.message || 'Failed to resend code. Please try again.';
            document.getElementById('otpError').style.display = 'block';
            resendBtn.innerHTML = originalText;
            resendBtn.disabled = false;
        }
    })
    .catch(function(error) {
        console.error('Error:', error);
        document.getElementById('otpError').textContent = 'An error occurred. Please try again.';
        document.getElementById('otpError').style.display = 'block';
        resendBtn.innerHTML = originalText;
        resendBtn.disabled = false;
    });
}

// ============================================================================
// UTILITY FUNCTIONS
// ============================================================================

function getContextPath() {
    const path = '${pageContext.request.contextPath}';
    return path || '';
}

function showLoading(show) {
    const loadingDiv = document.getElementById('loading-icon-bx');
    if (loadingDiv) {
        loadingDiv.style.display = show ? 'block' : 'none';
    }
}

function showAlert(message, type) {
    if (!type) type = 'info';
    
    const alertDiv = document.createElement('div');
    alertDiv.className = 'alert alert-' + type + ' alert-dismissible fade show';
    alertDiv.style.cssText = 'position: fixed; top: 20px; right: 20px; z-index: 9999; min-width: 300px;';

    let icon = 'fa-info-circle';
    if (type === 'success') icon = 'fa-check-circle';
    else if (type === 'warning') icon = 'fa-exclamation-triangle';
    else if (type === 'error' || type === 'danger') icon = 'fa-times-circle';

    alertDiv.innerHTML = 
        '<i class="fa ' + icon + '"></i> ' + message +
        '<button type="button" class="close" data-dismiss="alert" aria-label="Close">' +
            '<span aria-hidden="true">&times;</span>' +
        '</button>';

    document.body.appendChild(alertDiv);

    setTimeout(function() {
        if (alertDiv && alertDiv.parentNode) {
            alertDiv.remove();
        }
    }, 3000);

    const closeBtn = alertDiv.querySelector('.close');
    if (closeBtn) {
        closeBtn.addEventListener('click', function() {
            alertDiv.remove();
        });
    }
}

// ============================================================================
// BOOKING SUMMARY ENHANCEMENT FUNCTIONS
// ============================================================================

function adjustBookingSummaryPosition() {
    const bookingSummary = document.querySelector('.booking-summary');
    if (!bookingSummary) return;

    const header = document.querySelector('header') || 
                  document.querySelector('.header') || 
                  document.querySelector('#header') ||
                  document.querySelector('nav') ||
                  document.querySelector('.navbar') ||
                  document.querySelector('.main-header');

    if (header) {
        const headerHeight = header.offsetHeight;
        const topOffset = headerHeight + 20;
        
        bookingSummary.style.top = topOffset + 'px';
        
        const maxHeight = window.innerHeight - topOffset - 20;
        bookingSummary.style.maxHeight = maxHeight + 'px';
    } else {
        bookingSummary.style.top = '120px';
        bookingSummary.style.maxHeight = 'calc(100vh - 140px)';
    }
}

function handleBookingSummaryScroll() {
    const bookingSummary = document.querySelector('.booking-summary');
    if (!bookingSummary) return;

    let ticking = false;

    function updateShadow() {
        const scrollTop = window.pageYOffset || document.documentElement.scrollTop;
        
        if (scrollTop > 50) {
            bookingSummary.style.boxShadow = '0 8px 25px rgba(0,0,0,0.2)';
        } else {
            bookingSummary.style.boxShadow = '0 4px 15px rgba(0,0,0,0.1)';
        }
        
        ticking = false;
    }

    function requestTick() {
        if (!ticking) {
            requestAnimationFrame(updateShadow);
            ticking = true;
        }
    }

    window.addEventListener('scroll', requestTick);
}

function handleWindowResize() {
    let resizeTimeout;
    
    window.addEventListener('resize', function() {
        clearTimeout(resizeTimeout);
        resizeTimeout = setTimeout(function() {
            adjustBookingSummaryPosition();
        }, 250);
    });
}

// ============================================================================
// INITIALIZATION FUNCTIONS
// ============================================================================

function initializeServicesSection() {
    document.querySelectorAll('input[name="services"]').forEach(function(checkbox) {
        checkbox.addEventListener('change', function() {
            toggleServiceSelection(this);
        });
    });
    
    document.querySelectorAll('.service-item').forEach(function(item) {
        item.setAttribute('tabindex', '0');
        item.addEventListener('keydown', function(e) {
            if (e.key === 'Enter' || e.key === ' ') {
                e.preventDefault();
                const checkbox = this.querySelector('input[type="checkbox"]');
                checkbox.checked = !checkbox.checked;
                toggleServiceSelection(checkbox);
            }
        });
    });
    
    const servicesContainer = document.getElementById('servicesContainer');
    if (servicesContainer) {
        servicesContainer.addEventListener('scroll', function() {
            if (this.scrollTop > 0) {
                this.style.boxShadow = 'inset 0 10px 10px -10px rgba(0,0,0,0.1)';
            } else {
                this.style.boxShadow = 'none';
            }
        });
    }
}

function initializeAvailabilitySection() {
    showAvailabilityPlaceholder();
    
    const checkinInput = document.querySelector('input[name="checkinDate"]');
    const checkoutInput = document.querySelector('input[name="checkoutDate"]');
    
    if (checkinInput) {
        checkinInput.addEventListener('change', function() {
            updateCheckoutMin();
        });
    }
    
    if (checkoutInput) {
        checkoutInput.addEventListener('change', function() {
            calculateNights();
        });
    }
}

function checkUserLoginStatus() {
    const url = getContextPath() + '/BookingServlet?action=checkLogin';

    fetch(url)
    .then(function(response) {
        if (!response.ok) {
            throw new Error('Server responded with status: ' + response.status);
        }
        return response.json();
    })
    .then(function(data) {
        if (data.isLoggedIn && data.user) {
            updateFormWithUserData(data.user);

            const welcomeDiv = document.createElement('div');
            welcomeDiv.className = 'alert alert-info mb-3';
            welcomeDiv.innerHTML = '<i class="fa fa-user"></i> Booking as <strong>' + data.user.fullName + '</strong>';

            const contactSection = document.querySelector('h4').parentElement;
            if (contactSection) {
                contactSection.insertBefore(welcomeDiv, contactSection.firstChild);
            }
        }
    })
    .catch(function(error) {
        console.error('Error checking login status:', error);
    });
}

// ============================================================================
// MAIN INITIALIZATION
// ============================================================================

document.addEventListener('DOMContentLoaded', function () {
    const bookingForm = document.getElementById('bookingForm');
    if (!bookingForm) {
        console.error('Booking form not found!');
        return;
    }

    bookingForm.addEventListener('submit', function (e) {
        e.preventDefault();
        if (!validateBookingForm()) {
            return;
        }
        checkLoginAndProceed();
    });

    updateTotalPrice();
    updateGuestsDisplay();

    const today = new Date().toISOString().split('T')[0];
    const checkinInput = document.querySelector('input[name="checkinDate"]');
    if (checkinInput) {
        checkinInput.setAttribute('min', today);
    }

    checkUserLoginStatus();
    addFormValidationListeners();
    
    setTimeout(function() {
        initializeServicesSection();
        initializeAvailabilitySection();
        adjustBookingSummaryPosition();
        handleBookingSummaryScroll();
        handleWindowResize();
    }, 100);
});
</script>

    </body>
</html>