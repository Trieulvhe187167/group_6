<%@ page language="java" contentType="text/html; charset=UTF-8" import="model.Blog" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <head>  <meta charset="utf-8">
  <meta http-equiv="X-UA-Compatible" content="IE=edge">
  <meta name="keywords" content="" />
  <meta name="author" content="" />
  <meta name="robots" content="" />
  <meta name="description" content="Luxury Hotel" />
  <meta property="og:title" content="Luxury Hotel" />
  <meta property="og:description" content="Luxury Hotel" />
  <meta property="og:image" content="" />
  <meta name="format-detection" content="telephone=no">
  <link rel="icon" href="${pageContext.request.contextPath}/assets/images/favicon.ico" type="image/x-icon" />
  <link rel="shortcut icon" type="image/x-icon" href="${pageContext.request.contextPath}/assets/images/favicon.png" />
  <title>Blog Detail - Luxury Hotel</title>
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <!-- CSS -->
  <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/assets.css">
  <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/typography.css">
  <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/shortcodes/shortcodes.css">
  <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/style.css">
  <link class="skin" rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/color/color-1.css"></head>
    
  <body id="bg">
  <div class="page-wraper">
    <header class="header rs-nav">
      <%@ include file="header.jsp" %>
    </header>

<!-- Blog Details Page -->
<div class="page-content bg-white">
    <!-- inner page banner -->
    <!-- Inner Content Box -->
            <div class="page-content bg-white">
                <!-- Page Heading -->
                <div class="page-banner ovbl-dark" style="background-image:url(${pageContext.request.contextPath}/assets/images/banner/banner2.jpg);">
                    <div class="container">
                        <div class="page-banner-entry">
                            <h1 class="text-white">Blog - Detail</h1>
                        </div>
                    </div>
                </div>
                <div class="breadcrumb-row">
                    <div class="container">
                        <ul class="list-inline">
                            <li><a href="/index.jsp">Home</a></li>
                            <li><a href="${pageContext.request.contextPath}/jsp/blog.jsp">Blog</a></li>
                            <li>Blog Detail</li>
                        </ul>
                    </div>
                </div>
    <!-- Breadcrumb row -->
    <div class="page-content bg-white">
      <!-- Page banner và breadcrumb copy-y từ blogDetail.jsp -->
      <div class="content-block">
        <div class="section-area section-sp1">
          <div class="container">
            <div class="row">
              <div class="col-lg-8 col-xl-8">
                <!-- Hiển thị chi tiết blog -->
                <div class="recent-news blog-lg">
                  <div class="action-box blog-lg">
                    <img src="${pageContext.request.contextPath}/assets/images/blog/${blog.imageUrl}"
                         alt="${blog.title}" />
                  </div>
                  <div class="info-bx">
                    <ul class="media-post">
                      <li>
                        <a href="#"><i class="fa fa-calendar"></i>
                          <fmt:formatDate value="${blog.createdAt}" pattern="MMM dd, yyyy"/>
                        </a>
                      </li>
                      <li>
                        <a href="#"><i class="fa fa-comments-o"></i>
                          ${blog.commentCount} Comment
                        </a>
                      </li>
                    </ul>
                    <h5 class="post-title">${blog.title}</h5>
                    <div class="post-content">
                      <c:out value="${blog.content}" escapeXml="false"/>
                    </div>
                                <div class="ttr-divider bg-gray"><i class="icon-dot c-square"></i></div>
                                <div class="widget_tag_cloud">
                                    <h6>TAGS</h6>
                                    <div class="tagcloud">
                                        <!-- example static, replace with dynamic if available -->
                                        <c:forEach var="tag" items="${blog.tags}">
                                            <a href="#">${tag}</a>
                                        </c:forEach>
                                    </div>
                                </div>
                                <div class="ttr-divider bg-gray"><i class="icon-dot c-square"></i></div>
                                <h6>SHARE</h6>
                                  
      
                    <ul class="list-inline">
                        <li class="list-inline-item">
                            <a href="#" class="btn-link">
                                <i class="fab fa-facebook-f"></i>
                            </a>
                        </li>
                        <li class="list-inline-item">
                            <a href="#" class="btn-link">
                                <i class="fab fa-google-plus-g"></i>
                            </a>
                        </li>
                        <li class="list-inline-item">
                            <a href="#" class="btn-link">
                                <i class="fab fa-linkedin-in"></i>
                            </a>
                        </li>
                    </ul>
      
                                <div class="ttr-divider bg-gray"><i class="icon-dot c-square"></i></div>
                            </div>
                        </div>
                        <!-- blog END -->

                        <!-- Comments List -->
                        <div id="comment-list">
                            <!-- include your dynamic comments here or static template -->
                        </div>

                        <!-- Comment Form -->
                        <div class="comment-respond" id="respond">
                            <h4 class="comment-reply-title" id="reply-title">Leave a Reply</h4>
                            <form class="comment-form" id="commentform" method="post" action="${pageContext.request.contextPath}/CommentServlet">
                                <input type="hidden" name="blogId" value="${blog.id}" />
                                <p class="comment-form-author">
                                    <label for="author">Name <span class="required">*</span></label>
                                    <input type="text" name="author" id="author" placeholder="Your Name" required />
                                </p>
                                <p class="comment-form-email">
                                    <label for="email">Email <span class="required">*</span></label>
                                    <input type="email" name="email" id="email" placeholder="Your Email" required />
                                </p>
                                <p class="comment-form-comment">
                                    <label for="comment">Comment</label>
                                    <textarea name="comment" id="comment" rows="6" placeholder="Your Comment" required></textarea>
                                </p>
                                <p class="form-submit">
                                    <button type="submit" class="btn">Submit Comment</button>
                                </p>
                            </form>
                        </div>

                    </div>
                    <!-- Left part END -->

                    <!-- Side bar start -->
                    <div class="col-lg-4 col-xl-4">
                        <aside class="side-bar sticky-top">
                            <!-- Search Widget -->
                            <div class="widget">
                                <h6 class="widget-title">Search</h6>
                                <div class="search-bx style-1">
                                    <form role="search" method="get" action="/BlogSearchServlet">
                                        <div class="input-group">
                                            <input name="q" type="text" class="form-control" placeholder="Enter your keywords..." />
                                            <span class="input-group-btn">
                                                <button type="submit" class="fa fa-search text-primary"></button>
                                            </span>
                                        </div>
                                    </form>
                                </div>
                            </div>
                            <!-- Recent Posts Widget -->
                            <div class="widget recent-posts-entry">
                                <h6 class="widget-title">Recent Posts</h6>
                                <div class="widget-post-bx">
                                    <c:forEach var="rp" items="${recentPosts}">
                                        <div class="widget-post clearfix">
                                            <div class="ttr-post-media">
                                                <img src="${pageContext.request.contextPath}/assets/images/blog/${rp.imageUrl}" width="200" height="143" alt="${rp.title}" />
                                            </div>
                                            <div class="ttr-post-info">
                                                <div class="ttr-post-header">
                                                    <h6 class="post-title"><a href="/BlogDetailServlet?slug=${rp.slug}">${rp.title}</a></h6>
                                                </div>
                                                <ul class="media-post">
                                                    <li><a href="#"><i class="fa fa-calendar"></i><fmt:formatDate value="${rp.createdAt}" pattern="MMM dd yyyy"/></a></li>
                                                    <li><a href="#"><i class="fa fa-comments-o"></i>${rp.commentCount} Comment</a></li>
                                                </ul>
                                            </div>
                                        </div>
                                    </c:forEach>
                                </div>
                            </div>
              
                        </aside>
                    </div>
                    <!-- Side bar END -->

                </div>
            </div>
        </div>
    </div>

    <%@ include file="footer.jsp" %>
  </div> 
    <!-- JS -->
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
<script src="${pageContext.request.contextPath}/assets/js/functions.js"></script>
<script src="${pageContext.request.contextPath}/assets/js/contact.js"></script>

 </body>
 </html>