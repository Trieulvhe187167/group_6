<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8"/>
  <title><c:out value="${pageTitle != null ? pageTitle : 'LUXURY HOTEL'}"/></title>
  <base href="<c:url value='/'/>"/>

  <!-- CSS -->
  <link rel="icon" href="assets/images/favicon.ico" type="image/x-icon"/>
  <link rel="stylesheet" href="assets/css/assets.css"/>
  <link rel="stylesheet" href="assets/css/typography.css"/>
  <link rel="stylesheet" href="assets/css/shortcodes/shortcodes.css"/>
  <link rel="stylesheet" href="assets/css/style.css"/>
  <link rel="stylesheet" href="assets/css/color/color-1.css" class="skin"/>
  <link rel="stylesheet" href="assets/vendors/revolution/css/layers.css"/>
  <link rel="stylesheet" href="assets/vendors/revolution/css/settings.css"/>
  <link rel="stylesheet" href="assets/vendors/revolution/css/navigation.css"/>

  <!-- Spinner CSS -->
  <style>
    #loading-icon-bx {
      position: fixed; top:0; left:0; width:100%; height:100%;
      background:#fff; display:flex; align-items:center; justify-content:center; z-index:9999;
    }
    #loading-icon-bx .spinner {
      width:50px; height:50px; background:#f60;
      animation: spin 1s infinite linear;
    }
    @keyframes spin { to { transform:rotate(360deg); } }
  </style>
</head>
<body id="bg">
  <div id="loading-icon-bx">
    <div class="spinner"></div>
  </div>

  <header class="header rs-nav header-transparent">
    <!-- Top bar -->
    <div class="top-bar">
      <div class="container d-flex justify-content-between">
        <ul class="list-inline mb-0">
          <li class="list-inline-item"><a href="faq-1.html"><i class="fa fa-question-circle"></i>Ask a Question</a></li>
          <li class="list-inline-item"><a href="mailto:Support@website.com"><i class="fa fa-envelope-o"></i>Support@website.com</a></li>
        </ul>
        <ul class="list-inline mb-0">
          <li class="list-inline-item">
            <select class="header-lang-bx">
              <option data-icon="flag flag-uk">English UK</option>
              <option data-icon="flag flag-us">English US</option>
            </select>
          </li>
          <li class="list-inline-item"><a href="login.html">Login</a></li>
          <li class="list-inline-item"><a href="jsp/Register.jsp">Register</a></li>

        </ul>
      </div>
    </div>
    <!-- Main nav -->
    <div class="sticky-header navbar-expand-lg">
      <div class="menu-bar container clearfix">
        <a class="menu-logo" href="index.jsp"><img src="assets/images/logo-white.png" alt="logo"/></a>
        <button class="navbar-toggler collapsed menuicon" data-toggle="collapse" data-target="#menuDropdown">
          <span/><span/><span/>
        </button>
        <div class="secondary-menu">
          <ul class="list-inline mb-0">
            <li class="list-inline-item"><a href="#" class="btn-link"><i class="fa fa-facebook"></i></a></li>
            <li class="list-inline-item"><a href="#" class="btn-link"><i class="fa fa-google-plus"></i></a></li>
            <li class="list-inline-item"><a href="#" class="btn-link"><i class="fa fa-linkedin"></i></a></li>
            <li class="list-inline-item search-btn"><button id="quik-search-btn" class="btn-link"><i class="fa fa-search"></i></button></li>
          </ul>
        </div>
        <div class="nav-search-bar">
          <form action="#"><input type="text" placeholder="Type to search"/><span><i class="ti-search"></i></span></form>
          <span id="search-remove"><i class="ti-close"></i></span>
        </div>
        <nav class="menu-links collapse navbar-collapse" id="menuDropdown">
          <ul class="nav navbar-nav">
            <li class="nav-item active"><a class="nav-link" href="index.jsp">Home</a></li>
            <li class="nav-item"><a class="nav-link" href="jsp/About.jsp">About</a></li>
            <li class="nav-item"><a class="nav-link" href="RoomListServlet">List Room</a></li>
            <li class="nav-item"><a class="nav-link" href="jsp/ManagerCustomer.jsp">Contact</a></li>
          </ul>
          <div class="nav-social-link">
            <a href="#"><i class="fa fa-facebook"></i></a>
            <a href="#"><i class="fa fa-google-plus"></i></a>
            <a href="#"><i class="fa fa-linkedin"></i></a>
          </div>
        </nav>
      </div>
    </div>
  </header>
