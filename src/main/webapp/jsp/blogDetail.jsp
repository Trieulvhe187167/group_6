<%@ page language="java" contentType="text/html; charset=UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>

<jsp:include page="header.jsp" />

<!-- Blog Details Page -->
<div class="page-content bg-white">
    <!-- inner page banner -->
    <div class="page-banner ovbl-dark" style="background-image:url(${pageContext.request.contextPath}/assets/images/banner/banner2.jpg);">
        <div class="container">
            <div class="page-banner-entry">
                <h1 class="text-white">Blog Details</h1>
            </div>
        </div>
    </div>
    <!-- Breadcrumb row -->
    <div class="breadcrumb-row">
        <div class="container">
            <ul class="list-inline">
                <li><a href="${pageContext.request.contextPath}/">Home</a></li>
                <li>Blog Details</li>
            </ul>
        </div>
    </div>
    <!-- Breadcrumb row END -->
    <div class="content-block">
        <div class="section-area section-sp1">
            <div class="container">
                <div class="row">
                    <!-- Left part start -->
                    <div class="col-lg-8 col-xl-8">
                        <!-- blog start -->
                        <div class="recent-news blog-lg">
                            <div class="action-box blog-lg">
                                <img src="${pageContext.request.contextPath}/assets/images/blog/${blog.imageUrl}" alt="${blog.title}" />
                            </div>
                            <div class="info-bx">
                                <ul class="media-post">
                                    <li><a href="#"><i class="fa fa-calendar"></i><fmt:formatDate value="${blog.createdAt}" pattern="MMM dd, yyyy"/></a></li>
                                    <li><a href="#"><i class="fa fa-comments-o"></i>${blog.commentCount} Comment</a></li>
                                </ul>
                                <h5 class="post-title"><a href="#">${blog.title}</a></h5>
                                <!-- Blog content (HTML) -->
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
                                <ul class="list-inline contact-social-bx">
                                    <li><a href="#" class="btn outline radius-xl"><i class="fa fa-facebook"></i></a></li>
                                    <li><a href="#" class="btn outline radius-xl"><i class="fa fa-twitter"></i></a></li>
                                    <li><a href="#" class="btn outline radius-xl"><i class="fa fa-linkedin"></i></a></li>
                                    <li><a href="#" class="btn outline radius-xl"><i class="fa fa-google-plus"></i></a></li>
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
</div>

    <%@ include file="footer.jsp" %>
