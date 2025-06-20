<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>

<!-- L?y URI hi?n t?i -->
<c:set var="currentUrl" value="${pageContext.request.requestURI}" />
<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/5.15.4/css/all.min.css">

<%
    // Load room types for search dropdown
    dal.RoomTypeDAO roomTypeDAO = new dal.RoomTypeDAO();
    java.util.List<model.RoomType> searchRoomTypes = roomTypeDAO.getAllRoomTypesActive();
    request.setAttribute("searchRoomTypes", searchRoomTypes);
%>

<style>
    .user-info {
        display: inline-flex;
        align-items: center;
        margin-right: 10px;
    }
    .user-avatar {
        width: 25px;
        height: 25px;
        border-radius: 50%;
        margin-right: 8px;
        background-color: #fff;
        display: inline-flex;
        align-items: center;
        justify-content: center;
        font-weight: bold;
        color: #333;
    }
    .dropdown-menu {
        margin-top: 10px;
    }
    .dropdown-toggle::after {
        margin-left: 5px;
    }
    .user-dropdown {
        position: relative;
        display: inline-block;
    }
    
    /* Compact Hotel Search Form Styles with Transparent Background */
    .hotel-search-form {
        display: flex;
        align-items: center;
        background: rgba(255, 255, 255, 0.15); /* Semi-transparent white */
        backdrop-filter: blur(10px); /* Blur effect */
        -webkit-backdrop-filter: blur(10px); /* Safari support */
        border-radius: 5px;
        padding: 2px;
        box-shadow: 0 2px 10px rgba(0,0,0,0.1);
        margin-left: auto;
        margin-right: 10px;
        height: 38px; /* Reduced height */
        border: 1px solid rgba(255, 255, 255, 0.2);
    }
    
    .search-field {
        display: flex;
        align-items: center;
        padding: 0 10px; /* Reduced padding */
        border-right: 1px solid rgba(255, 255, 255, 0.3);
        height: 34px; /* Reduced height */
        position: relative;
    }
    
    .search-field:last-of-type {
        border-right: none;
    }
    
    .search-field i {
        color: rgba(255, 255, 255, 0.8); /* White icons */
        margin-right: 6px;
        font-size: 12px; /* Smaller icons */
    }
    
    .search-field input,
    .search-field select {
        border: none;
        outline: none;
        background-color: transparent;
        font-size: 12px; /* Smaller font */
        color: #fff; /* White text */
    }
    
    .search-field input::placeholder {
        color: rgba(255, 255, 255, 0.7);
    }
    
    /* Style select dropdowns */
    .search-field select {
        color: #fff;
        background-color: transparent;
        border: none;
        cursor: pointer;
    }
    
    /* Bootstrap-select Overrides */
    .search-field .bootstrap-select>.btn {
        background-color: transparent !important;
        border: none !important;
        box-shadow: none !important;
        color: #fff !important;
        /* Ensure text is white */
        padding-left: 0;
        /* Align with other fields */
        padding-right: 0;
    }

    .search-field .bootstrap-select .filter-option {
        font-size: 12px;
    }

    /* Set caret color to white */
    .search-field .bootstrap-select .bs-caret .caret {
        border-top-color: white;
    }

    /* Style for the dropdown menu itself */
    .bootstrap-select.open>.dropdown-menu {
        background: #333;
        /* Dark background */
    }

    /* Style for individual options */
    .bootstrap-select .dropdown-menu li a {
        color: #333 !important;
        /* Dark text */
    }

    /* Style for hovered or selected options */
    .bootstrap-select .dropdown-menu li.selected a,
    .bootstrap-select .dropdown-menu li a:hover {
        background: #FFD700 !important;
        /* Yellow highlight */
        color: #333 !important;
        /* Dark text on highlight */
    }
    
    /* Room type field */
    .roomtype-field {
        min-width: 110px; /* Reduced width */
    }
    
    .roomtype-field select {
        width: 100px;
        cursor: pointer;
        padding-right: 15px;
    }
    
    /* Date fields */
    .date-field {
        min-width: 95px; /* Reduced width */
        cursor: pointer;
    }
    
    .date-field input {
        cursor: pointer;
        width: 80px; /* Reduced width */
        font-size: 11px; /* Smaller font */
        color: #fff;
    }
    
    /* Date input text color - make it white */
    .date-field input::-webkit-datetime-edit,
    .date-field input::-webkit-datetime-edit-fields-wrapper,
    .date-field input::-webkit-datetime-edit-text,
    .date-field input::-webkit-datetime-edit-month-field,
    .date-field input::-webkit-datetime-edit-day-field,
    .date-field input::-webkit-datetime-edit-year-field {
        color: #fff;
    }
    
    /* Calendar icon color */
    .date-field input::-webkit-calendar-picker-indicator {
        filter: invert(1);
        opacity: 0.8;
        cursor: pointer;
    }
    
    /* Date input focus state */
    .date-field input:focus {
        outline: 1px solid #FFD700;
        outline-offset: -1px;
    }
    
    /* Date field hover effect */
    .date-field:hover {
        background: rgba(255, 215, 0, 0.1); /* Light yellow hover */
    }
    
    .date-label {
        position: absolute;
        top: -5px;
        left: 20px;
        font-size: 9px; /* Smaller label */
        color: rgba(255, 255, 255, 0.9);
        background: transparent;
        padding: 0 2px;
    }
    
    /* Occupancy field */
    .occupancy-field {
        min-width: 100px; /* Reduced width */
    }
    
    .occupancy-field select {
        width: 85px; /* Reduced width */
        cursor: pointer;
        font-size: 11px; /* Smaller font */
    }
    
    /* Search button */
    .search-submit-btn {
        background: rgba(0, 53, 128, 0.9); /* Semi-transparent blue */
        color: white;
        border: none;
        padding: 0 15px; /* Reduced padding */
        height: 34px; /* Reduced height */
        border-radius: 3px;
        font-size: 13px; /* Smaller font */
        font-weight: 600;
        cursor: pointer;
        transition: all 0.3s;
        margin: 0 2px;
        white-space: nowrap;
    }
    
    .search-submit-btn:hover {
        background: rgba(0, 34, 79, 0.95);
        transform: translateY(-1px);
    }
    
    /* Custom date picker styling */
    .date-picker-wrapper {
        position: relative;
    }
    
    input[type="date"]::-webkit-calendar-picker-indicator {
        position: absolute;
        right: 0;
        width: 100%;
        height: 100%;
        opacity: 0;
        cursor: pointer;
    }
    
    /* Style for date inputs */
    input[type="date"] {
        position: relative;
        cursor: pointer;
    }
    
    /* Invalid date warning */
    input[type="date"]:invalid {
        border-color: #ff6b6b;
    }
    
    /* Hide the old search elements */
    .nav-search-bar,
    .secondary-menu > ul {
        display: none !important;
    }
    
    /* Adjust secondary menu */
    .secondary-menu {
        display: flex;
        align-items: center;
        flex: 1;
        justify-content: flex-end;
    }
    
    /* Responsive - hide on smaller screens */
    @media (max-width: 1200px) {
        .hotel-search-form {
            display: none;
        }
    }
    
    /* Highlight class for selected dropdowns */
    .search-field select.selected-highlight {
        color: #FFD700 !important; /* Yellow text when selected */
        font-weight: 600;
    }
    
    /* Parent field with selection */
    .search-field.has-selection {
        background: rgba(255, 215, 0, 0.1);
    }
    
    .search-field.has-selection i {
        color: #FFD700 !important;
    }
    
    /* Arrow color for highlighted select */
    .search-field select.selected-highlight {
        background-image: url("data:image/svg+xml;charset=UTF-8,%3csvg xmlns='http://www.w3.org/2000/svg' viewBox='0 0 24 24' fill='none' stroke='%23FFD700' stroke-width='2' stroke-linecap='round' stroke-linejoin='round'%3e%3cpolyline points='6 9 12 15 18 9'%3e%3c/polyline%3e%3c/svg%3e") !important;
    }
    
    /* Hover effect for all fields */
    .search-field:hover {
        background: rgba(255, 215, 0, 0.1); /* Light yellow hover */
    }
    
    /* Active/focus state for fields */
    .search-field.is-focused {
        background: rgba(255, 215, 0, 0.15); /* Stronger yellow when focused */
        border-right-color: rgba(255, 215, 0, 0.3);
    }
    
    /* Dropdown open state */
    .search-field select:focus,
    .search-field select:active {
        background: transparent; /* Keep transparent background */
    }
    
    /* For browsers that don't support backdrop-filter */
    @supports not (backdrop-filter: blur(10px)) {
        .hotel-search-form {
            background: rgba(255, 255, 255, 0.25);
        }
    }
</style>

<header class="header rs-nav header-transparent">

    <!-- Top bar -->
    <div class="top-bar">
        <div class="container d-flex justify-content-between">
            <ul class="list-inline mb-0">
                <li class="list-inline-item">
                    <a href="<c:url value='/faq-1.html'/>"><i class="fa fa-question-circle"></i>Ask a Question</a>
                </li>
                <li class="list-inline-item">
                    <a href="https://mail.google.com/mail/?view=cm&fs=1&to=luxuryhotel999@gmail.com&su=Feedback%20from%20Website&body=Hello%20Luxury%20Hotel," target="_blank" rel="noopener">
                        <i class="fa fa-envelope-o"></i>
                        luxuryhotel999@gmail.com
                    </a>
                </li>
            </ul>
            <ul class="list-inline mb-0">
                <c:choose>
                    <c:when test="${not empty sessionScope.user}">
                        <!-- User is logged in -->
                        <li class="list-inline-item">
                            <div class="user-dropdown dropdown">
                                <a href="#" class="dropdown-toggle" data-toggle="dropdown" aria-haspopup="true" aria-expanded="false">
                                    <span class="user-info">
                                        <span class="user-avatar">
                                            ${fn:substring(sessionScope.user.fullName, 0, 1)}
                                        </span>
                                        Welcome, ${sessionScope.user.fullName}
                                    </span>
                                </a>
                                <div class="dropdown-menu dropdown-menu-right">
                                    <!-- Show different options based on role -->
                                    <c:choose>
                                        <c:when test="${sessionScope.user.role eq 'ADMIN'}">
                                            <a class="dropdown-item" href="${pageContext.request.contextPath}/admin-dashboard">
                                                <i class="fa fa-tachometer-alt"></i> Dashboard
                                            </a>
                                            <a class="dropdown-item" href="${pageContext.request.contextPath}/admin/users">
                                                <i class="fa fa-users"></i> Manage Users
                                            </a>
                                            <a class="dropdown-item" href="${pageContext.request.contextPath}/HouseKeeping">
                                                <i class="fa fa-users"></i> Manage Housekeeping
                                            </a>
                                            <div class="dropdown-divider"></div>
                                        </c:when>
                                        <c:when test="${sessionScope.user.role eq 'RECEPTIONIST'}">
                                            <a class="dropdown-item" href="${pageContext.request.contextPath}/receptionist/bookings">
                                                <i class="fa fa-calendar-check"></i> Manage Bookings
                                            </a>
                                            <a class="dropdown-item" href="${pageContext.request.contextPath}/receptionist/checkin">
                                                <i class="fa fa-sign-in-alt"></i> Check-in/Check-out
                                            </a>
                                            <div class="dropdown-divider"></div>
                                        </c:when>
                                        <c:when test="${sessionScope.user.role eq 'HOUSEKEEPER'}">
                                            <a class="dropdown-item" href="${pageContext.request.contextPath}/housekeeper/tasks">
                                                <i class="fa fa-tasks"></i> My Tasks
                                            </a>
                                            <a class="dropdown-item" href="${pageContext.request.contextPath}/housekeeper/task-detail">
                                                <i class="fa fa-bed"></i> Room Status
                                            </a>
                                            <div class="dropdown-divider"></div>
                                        </c:when>
                                        <c:when test="${sessionScope.user.role eq 'CUSTOMER'}">
                                            <a class="dropdown-item" href="${pageContext.request.contextPath}/customer/profile">
                                                <i class="fa fa-user"></i> My Profile
                                            </a>
                                            <a class="dropdown-item" href="${pageContext.request.contextPath}/customer/bookings">
                                                <i class="fa fa-calendar"></i> My Bookings
                                            </a>
                                            <a class="dropdown-item" href="${pageContext.request.contextPath}/customer/history">
                                                <i class="fa fa-history"></i> Booking History
                                            </a>
                                            <div class="dropdown-divider"></div>
                                        </c:when>
                                    </c:choose>
                                    
                                    <!-- Common items for all users -->
                                    <a class="dropdown-item" href="${pageContext.request.contextPath}/reset-password">
                                        <i class="fa fa-key"></i> Change Password
                                    </a>
                                    <a class="dropdown-item" href="${pageContext.request.contextPath}/LogoutServlet">
                                        <i class="fa fa-sign-out-alt"></i> Logout
                                    </a>
                                </div>
                            </div>
                        </li>
                    </c:when>
                    <c:otherwise>
                        <!-- User is not logged in -->
                        <li class="list-inline-item">
                            <svg xmlns="http://www.w3.org/2000/svg"
                                 fill="none"
                                 viewBox="0 0 24 24"
                                 stroke-width="1.5"
                                 stroke="currentColor"
                                 class="size-6"
                                 style="width:1.3em; height:1.3em; vertical-align:middle;">
                                <path stroke-linecap="round" stroke-linejoin="round"
                                      d="M15.75 6a3.75 3.75 0 1 1-7.5 0 3.75 3.75 0 0 1 7.5 0ZM4.501 20.118a7.5 7.5 0 0 1 14.998 0A17.933 17.933 0 0 1 12 21.75c-2.676 0-5.216-.584-7.499-1.632Z"/>
                            </svg>
                            <a href="<c:url value='/jsp/login.jsp'/>">Login</a>
                        </li>
                        <li class="list-inline-item">
                            <a href="<c:url value='/jsp/Register.jsp'/>">Register</a>
                        </li>
                    </c:otherwise>
                </c:choose>
            </ul>
        </div>
    </div>

    <!-- Main nav -->
    <div class="sticky-header navbar-expand-lg">
        <div class="menu-bar container clearfix">
            <a class="menu-logo" href="<c:url value='/index.jsp'/>">
                <img src="${pageContext.request.contextPath}/assets/images/logo-white.png" alt="Luxury Hotel Logo"/>
            </a>
            <button class="navbar-toggler collapsed menuicon" data-toggle="collapse" data-target="#menuDropdown" aria-label="Toggle navigation">
                <span></span><span></span><span></span>
            </button>

            <!-- Compact Hotel Search Form -->
            <div class="secondary-menu">
                <form action="${pageContext.request.contextPath}/SearchAvailableRoomsServlet" method="GET" class="hotel-search-form">
                    <!-- Room Type -->
                    <div class="search-field roomtype-field">
                        <i class="fa fa-bed"></i>
                        <select name="roomTypeId" id="roomTypeId">
                            <option value="">All Room Types</option>
                            <c:forEach var="roomType" items="${searchRoomTypes}">
                                <option value="${roomType.id}" 
                                    <c:if test="${searchRoomTypeId eq roomType.id}">selected</c:if>>
                                    ${roomType.name}
                                </option>
                            </c:forEach>
                        </select>
                    </div>
                    
                    <!-- Check-in -->
                    <div class="search-field date-field">
                        <div class="date-picker-wrapper">
                            <span class="date-label">Check in</span>
                            <i class="fa fa-calendar"></i>
                            <input type="date" id="checkIn" name="checkIn" 
                                   value="${searchCheckIn}" 
                                   title="Select check-in date (today or future)"
                                   required>
                        </div>
                    </div>
                    
                    <!-- Check-out -->
                    <div class="search-field date-field">
                        <div class="date-picker-wrapper">
                            <span class="date-label">Check out</span>
                            <i class="fa fa-calendar"></i>
                            <input type="date" id="checkOut" name="checkOut" 
                                   value="${searchCheckOut}" 
                                   title="Select check-out date (must be after check-in)"
                                   required>
                        </div>
                    </div>
                    
                    <!-- Occupancy -->
                    <div class="search-field occupancy-field">
                        <i class="fa fa-user"></i>
                        <select name="capacity" id="capacity">
                            <option value="1" <c:if test="${searchCapacity eq '1'or empty searchCapacity}">selected</c:if>>1 guest</option>
                            <option value="2" <c:if test="${searchCapacity eq '2' }">selected</c:if>>2 guests</option>
                            <option value="3" <c:if test="${searchCapacity eq '3'}">selected</c:if>>3 guests</option>
                            <option value="4" <c:if test="${searchCapacity eq '4'}">selected</c:if>>4 guests</option>
                        </select>
                    </div>
                    
                    <!-- Search Button -->
                    <button type="submit" class="search-submit-btn">Search</button>
                </form>
            </div>

            <!-- Menu Links -->
            <nav class="menu-links collapse navbar-collapse" id="menuDropdown">
                <ul class="nav navbar-nav">
                    <li class="nav-item ${fn:endsWith(currentUrl,'/index.jsp') ? 'active' : ''}">
                        <a class="nav-link" href="${pageContext.request.contextPath}/index.jsp">HOME</a>
                    </li>
                    <li class="nav-item ${fn:endsWith(currentUrl,'/About.jsp') ? 'active' : ''}">
                        <a class="nav-link" href="${pageContext.request.contextPath}/jsp/About.jsp">ABOUT</a>
                    </li>
                    <li class="nav-item ${fn:endsWith(currentUrl,'/roomList.jsp') ? 'active' : ''}">
                        <a class="nav-link" href="${pageContext.request.contextPath}/RoomListServlet">LIST ROOM</a>
                    </li>
                    <li class="nav-item ${fn:endsWith(currentUrl,'/contact.jsp') ? 'active' : ''}">
                        <a class="nav-link" href="${pageContext.request.contextPath}/jsp/contact.jsp">CONTACT</a>
                    </li>
                    <li class="nav-item ${fn:endsWith(currentUrl,'/blog.jsp') ? 'active' : ''}">
                        <a class="nav-link" href="${pageContext.request.contextPath}/BlogListServlet">BLOG</a>
                    </li>
                </ul>
            </nav>
        </div>
    </div>
</header>

<!-- Add necessary JavaScript -->
<script>
    $(document).ready(function() {
        // Initialize dropdown
        $('.dropdown-toggle').dropdown();
        
        // Function to add highlight class to selected dropdowns
        function updateDropdownHighlight() {
            // Room Type dropdown
            if ($('#roomTypeId').val() !== '') {
                $('#roomTypeId').addClass('selected-highlight');
                $('#roomTypeId').parent().addClass('has-selection');
            } else {
                $('#roomTypeId').removeClass('selected-highlight');
                $('#roomTypeId').parent().removeClass('has-selection');
            }
            
            // Capacity dropdown - highlight if not default (2 guests)
            if ($('#capacity').val() !== '2') {
                $('#capacity').addClass('selected-highlight');
                $('#capacity').parent().addClass('has-selection');
            } else {
                $('#capacity').removeClass('selected-highlight');
                $('#capacity').parent().removeClass('has-selection');
            }
        }
        
        // Apply highlight on page load
        updateDropdownHighlight();
        
        // Apply highlight when dropdown changes
        $('#roomTypeId, #capacity').on('change', function() {
            updateDropdownHighlight();
        });
        
        // Get today's date and format it
        var today = new Date();
        var dd = String(today.getDate()).padStart(2, '0');
        var mm = String(today.getMonth() + 1).padStart(2, '0');
        var yyyy = today.getFullYear();
        var todayStr = yyyy + '-' + mm + '-' + dd;
        
        // Set min attribute for check-in (today)
        document.getElementById('checkIn').setAttribute('min', todayStr);
        
        // Set default check-in to today if empty
        if (!$('#checkIn').val()) {
            $('#checkIn').val(todayStr);
        }
        
        // Function to update check-out min date
        function updateCheckOutMin() {
            var checkInVal = $('#checkIn').val();
            if (checkInVal) {
                var checkInDate = new Date(checkInVal);
                checkInDate.setDate(checkInDate.getDate() + 1);
                
                var dd = String(checkInDate.getDate()).padStart(2, '0');
                var mm = String(checkInDate.getMonth() + 1).padStart(2, '0');
                var yyyy = checkInDate.getFullYear();
                var minCheckOut = yyyy + '-' + mm + '-' + dd;
                
                document.getElementById('checkOut').setAttribute('min', minCheckOut);
                
                // Update check-out value if it's invalid
                if (!$('#checkOut').val() || $('#checkOut').val() <= checkInVal) {
                    $('#checkOut').val(minCheckOut);
                }
            }
        }
        
        // Initial setup for check-out
        updateCheckOutMin();
        
        // Update when check-in changes
        $('#checkIn').on('change', function() {
            updateCheckOutMin();
        });
        
        // Form validation
        $('.hotel-search-form').on('submit', function(e) {
            var checkIn = $('#checkIn').val();
            var checkOut = $('#checkOut').val();
            
            if (!checkIn || !checkOut) {
                e.preventDefault();
                alert('Please select both check-in and check-out dates');
                return false;
            }
            
            // Validate dates
            var checkInDate = new Date(checkIn);
            var checkOutDate = new Date(checkOut);
            var todayDate = new Date(todayStr);
            
            if (checkInDate < todayDate) {
                e.preventDefault();
                alert('Check-in date cannot be in the past');
                $('#checkIn').val(todayStr);
                return false;
            }
            
            if (checkOutDate <= checkInDate) {
                e.preventDefault();
                alert('Check-out date must be after check-in date');
                updateCheckOutMin();
                return false;
            }
        });

        // Add focus/blur states for search fields
        $('.search-field input, .bootstrap-select > .btn').on('focus', function() {
            $(this).closest('.search-field').addClass('is-focused');
        }).on('blur', function() {
            $(this).closest('.search-field').removeClass('is-focused');
        });
    });
</script>