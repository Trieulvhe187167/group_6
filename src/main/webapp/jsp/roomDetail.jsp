
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@ page import="model.RoomType" %>
<%@ page import="model.Room" %>
<%@ page import="model.Feedback" %>
<%@ page import="java.util.Map, java.util.stream.Collectors" %>
<%@ page import="model.Service" %>
<%@ page import="dal.RoomTypeDAO" %>
<%@ page import="dal.RoomDAO" %>
<%@ page import="dal.ServiceDAO" %>
<%@ page import="java.util.List" %>
<%@ page import="java.util.Arrays" %>
<%@ page import="java.text.DecimalFormat" %>
<%@ page import="java.io.File" %>
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
                0% {
                    transform: rotate(0deg);
                }
                100% {
                    transform: rotate(360deg);
                }
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
                0% {
                    border-color: #ff6b6b;
                }
                50% {
                    border-color: #ff9999;
                }
                100% {
                    border-color: #ff6b6b;
                }
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
                0% {
                    background: #ff6b6b;
                    color: white;
                }
                100% {
                    background: #fff5f5;
                    color: inherit;
                }
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
            .room-gallery .item img {
                width: 100%;
                height: 500px;
                object-fit: cover;
                border-radius: 10px;
            }
            /* Cho khung popup hơi mờ nền */
            .mfp-bg {
                opacity: 0.8 !important;
            }
            /* Cho ảnh trong popup bo góc nhẹ */
            .mfp-img {
                border-radius: 8px;
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
                
                List<Feedback> feedbackList = (List<Feedback>) request.getAttribute("feedbackList");
                 int totalReviews = feedbackList != null ? feedbackList.size() : 0;
                double avgRating = 0;
                Map<Integer, Long> ratingCounts = Map.of(1,0L,2,0L,3,0L,4,0L,5,0L);
                if (totalReviews > 0) {
                    avgRating = feedbackList.stream()
                        .mapToInt(Feedback::getRating)
                        .average().orElse(0);
                    ratingCounts = feedbackList.stream()
                        .collect(Collectors.groupingBy(Feedback::getRating, Collectors.counting()));
                }
            %>

            <!-- Content -->
            <div class="page-content bg-white">
                <!-- inner page banner -->
                <div class="page-banner ovbl-dark" style="background-image:url(assets/images/banner/banner2.jpg);">
                    <div class="container">
                        <div class="page-banner-entry">
                            <h1 class="text-white">Room Detail</h1>
                            </div>
                        </div>
                    </div>
                </div>

                <!-- Breadcrumb row -->
                <div class="breadcrumb-row">
                    <div class="container">
                        <ul class="list-inline">
                            <li><a href="#">Home</a></li>
                            <li><a href="SearchAvailableRoomsServlet">Room List</a></li>
                            <li>Room Detail</li>
                        </ul>
                    </div>
                </div>

                <!-- Booking Section -->
                <div class="section-area section-sp1 booking-section">
                    <div class="container">


                        <div class="row">
                            <!-- Left Column - Room Details & Booking Form -->
                            <div class="col-lg-12">
                                <div class="booking-form">
                                    <!-- Room Gallery -->
                                    <!-- Room Gallery Slider -->
                                    <div class="room-gallery owl-carousel owl-theme">
                                        <%
                                            // Lấy đường dẫn tuyệt đối đến thư mục chứa ảnh
                                            String imgDirPath = application.getRealPath("/") 
                                                + "assets/images/room-type/" + roomTypes.getName();
                                            File imgDir = new File(imgDirPath);
                                            // Lọc các file ảnh theo đuôi
                                            File[] imageFiles = imgDir.listFiles((dir, name) -> {
                                                String low = name.toLowerCase();
                                                return low.endsWith(".jpg") 
                                                    || low.endsWith(".jpeg") 
                                                    || low.endsWith(".png") 
                                                    || low.endsWith(".webp");
                                            });
                                            if (imageFiles != null) {
                                                // Sắp xếp tên file (nếu cần)
                                                Arrays.sort(imageFiles);
                                                for (File img : imageFiles) {
                                        %>
                                        <div class="item">
                                            <a href="${pageContext.request.contextPath}/assets/images/room-type/<%= roomTypes.getName() %>/<%= img.getName() %>" class="image-popup">
                                                <img 
                                                    src="${pageContext.request.contextPath}/assets/images/room-type/<%= roomTypes.getName() %>/<%= img.getName() %>" 
                                                    alt="<%= roomTypes.getName() %>" 
                                                    class="main-image"
                                                    >
                                            </a>
                                        </div>
                                        <%
                                                }
                                            } else {
                                        %>
                                        <div class="item">
                                            <img 
                                                src="${pageContext.request.contextPath}/assets/images/room-type/default.jpg" 
                                                alt="No image" 
                                                class="main-image"
                                                >
                                        </div>
                                        <%
                                            }
                                        %>
                                    </div>


                                    <!-- Room Info -->
                                    <div class="room-info mb-4">
                                        <div class="d-flex justify-content-between align-items-start mb-3">
                                            <div>
                                                <h2 class="post-title mb-2"><%= roomTypes.getName() %></h2>
                                                <div class="rating">
                                                    <% for(int i=1; i<=5; i++){
                                                           String cls;
                                                           if(avgRating >= i){
                                                               cls = "fa-star";
                                                           } else if(avgRating >= i - 0.5){
                                                               cls = "fa-star-half-o";
                                                           } else {
                                                               cls = "fa-star-o";
                                                           }
                                                    %>
                                                        <i class="fa <%= cls %> text-warning"></i>
                                                    <% } %>
                                                    <span class="text-muted ml-2"><%= String.format("%.1f", avgRating) %> (<%= totalReviews %> reviews)</span>
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

                                    <!-- Booking section moved to separate page -->
                                    <div class="text-center mb-4">
                                        <% 
     String searchIn = (String) request.getAttribute("searchCheckIn");
     String searchOut = (String) request.getAttribute("searchCheckOut");
     String bookingUrl = request.getContextPath() + "/jsp/booking.jsp?roomTypeId=" + id +
             "&roomTypeName=" + java.net.URLEncoder.encode(roomTypes.getName(), "UTF-8") +
             "&price=" + roomTypes.getBasePrice();
     if(searchIn != null && searchOut != null){
         bookingUrl += "&checkIn=" + searchIn + "&checkOut=" + searchOut;
     }
                                        %>
                                       
                                                        
                                         <a href="<%= bookingUrl %>" class="btn btn-primary me-2">Book this room</a>
                                        <%
                                            Integer avail = (Integer) request.getAttribute("availableCount");
                                            String addUrl = null;
                                            if(searchIn != null && searchOut != null && (avail == null || avail > 0)){
                                                addUrl = "CartServlet?action=add&roomTypeId=" + id +
                                                        "&roomTypeName=" + java.net.URLEncoder.encode(roomTypes.getName(), "UTF-8") +
                                                        "&price=" + roomTypes.getBasePrice() +
                                                        "&checkIn=" + searchIn + "&checkOut=" + searchOut;
                                            }
                                            if(addUrl != null){
                                        %>
                                            <a href="<%= addUrl %>" class="btn btn-success">Add to Cart</a>
                                        <%
                                            } else if(searchIn != null && searchOut != null){
                                        %>
                                            <span class="btn btn-secondary disabled">Sold Out</span>
                                        <%
                                            }
                                        %>
                                    </div>
                                    <a href="javascript:history.back()" class="btn btn-outline-secondary px-4">
    <i class="fas fa-arrow-left"></i> Back
  </a>
                                </div>
                                        <!-- Feedback Section -->
                     

                          <div class="feedback-container mt-5">
                                <!-- Reviews Summary -->
                                <div class="reviews-summary me-4">
                                    <div class="d-flex align-items-center">
                                       
                                            <h1 class="display-4 mb-0"><%= String.format("%.1f", avgRating) %></h1>
                                            <div class="star-rating">
                                                <% for(int i=1; i<=5; i++){ %>
                                                    <i class="fa fa-star text-warning"></i>
                                                <% } %>
                                            </div>
                                            
                                            <div class="text-muted"><%= totalReviews %> reviews</div>
                                       
                                 
                                    </div>
                                        <div class="mt-4">
                                        <% for(int star=5; star>=1; star--){ 
                                             long count = ratingCounts.getOrDefault(star, 0L);
                                             int pct = totalReviews>0 ? (int)(count * 100 / totalReviews) : 0;
                                        %>
                                        <div class="d-flex align-items-center mb-2">
                                            <span class="me-2"><%= star %> <i class="fa fa-star text-warning"></i></span>
                                            <div class="progress flex-grow-1 me-2" style="height:6px;">
                                                <div class="progress-bar bg-warning" role="progressbar"
                                                     style="width: <%= pct %>%;" aria-valuenow="<%= pct %>"
                                                     aria-valuemin="0" aria-valuemax="100"></div>
                                            </div>
                                            <span>(<%= count %>)</span>

                               
                                        </div>
                                 <% } %>
                                    </div>
                              
                                </div>
                                      <!-- Reviews List -->
                                <div class="reviews-list flex-grow-1">
                                    <h4 class="mb-4" style="color: lightcoral">User Reviews</h4>
                                    <% if (feedbackList != null && !feedbackList.isEmpty()) {
                                           java.text.SimpleDateFormat sdf = new java.text.SimpleDateFormat("dd/MM/yyyy");
                                           for (Feedback fb : feedbackList) {
                                    %>
                                    <div class="review-item">
                                        <div class="review-header d-flex justify-content-between align-items-center">
                                            <strong><%= fb.getUserFullName() %></strong>
                                            <small class="text-muted"><%= sdf.format(fb.getCreatedAt()) %></small>
                                        </div>
                                        <div class="mt-1">
                                            <% for(int i=1; i<=5; i++){
                                                  String cls = i <= fb.getRating() ? "fa-star" : "fa-star-o text-muted";
                                            %>
                                                <i class="fa <%= cls %> text-warning"></i>
                                            <% } %>
                                        </div>
                                        <p class="mt-2"><%= fb.getComment() %></p>
                         
                                    </div>
                                    <%   }
                                       } else { %>
                                       <p class="text-muted">There are no reviews yet.</p>
                                    <% } %>
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
       
                            </div>
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
                            $(document).ready(function () {
                                // 1. Khởi tạo Owl Carousel
                                $(".room-gallery").owlCarousel({
                                    items: 1,
                                    loop: true,
                                    nav: true,
                                    dots: true,
                                    autoplay: true,
                                    autoplayTimeout: 5000,
                                    navText: ['<i class="fa fa-chevron-left"></i>', '<i class="fa fa-chevron-right"></i>']
                                });

                                // 2. Khởi tạo Magnific Popup cho gallery
                                $('.room-gallery').magnificPopup({
                                    delegate: 'a.image-popup', // chọn các <a> chứa ảnh
                                    type: 'image',
                                    gallery: {
                                        enabled: true, // bật navigation giữa các ảnh
                                        navigateByImgClick: true,
                                        preload: [0, 2] // preload trước/sau 2 ảnh
                                    },
                                    zoom: {
                                        enabled: true,
                                        duration: 300, // thời gian zoom
                                        opener: function (el) {
                                            return el.find('img');
                                        }
                                    }
                                });
                            });
                        </script>

                        </body>
                    
                        </html>
                        