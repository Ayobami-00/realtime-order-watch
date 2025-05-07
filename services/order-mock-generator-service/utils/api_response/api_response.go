package api_response

import (
	"net/http"

	"github.com/Ayobami-00/Eureka/eureka-api-gateway-go/pkg/auth/pb"
	"github.com/gin-gonic/gin"
	"google.golang.org/grpc/codes"
)

func Respond(ctx *gin.Context, response interface{}) interface{} {

	switch r := response.(type) {

	case *pb.RegisterResponse:

		rr := r

		switch rr.Code {

		case int64(codes.OK):

			ctx.JSON(http.StatusOK, gin.H{
				"status":  "success",
				"message": rr.Message,
			})

		case int64(codes.Internal):

			ctx.JSON(http.StatusInternalServerError, BaseErrorResponse(rr.Message))

		case int64(codes.InvalidArgument):

			ctx.JSON(http.StatusBadRequest, BaseErrorResponse(rr.Message))

		case int64(codes.NotFound):

			ctx.JSON(http.StatusNotFound, BaseErrorResponse(rr.Message))

		case int64(codes.AlreadyExists):

			ctx.JSON(http.StatusNotFound, BaseErrorResponse(rr.Message))

		default:

			return nil

		}

	case *pb.LoginResponse:

		rr := r

		switch rr.Code {

		case int64(codes.OK):

			ctx.JSON(http.StatusOK, gin.H{
				"status":  "success",
				"message": rr.Message,
				"data": gin.H{
					"session_id":               rr.SessionId,
					"access_token":             rr.AccessToken,
					"access_token_expires_at":  rr.AccessTokenExpiresAt,
					"refresh_token":            rr.RefreshToken,
					"refresh_token_expires_at": rr.RefreshTokenExpiresAt,
					"user_id":                  rr.UserId,
				},
			})

		case int64(codes.Internal):

			ctx.JSON(http.StatusInternalServerError, BaseErrorResponse(rr.Message))

		case int64(codes.InvalidArgument):

			ctx.JSON(http.StatusBadRequest, BaseErrorResponse(rr.Message))

		case int64(codes.NotFound):

			ctx.JSON(http.StatusNotFound, BaseErrorResponse(rr.Message))

		case int64(codes.AlreadyExists):

			ctx.JSON(http.StatusNotFound, BaseErrorResponse(rr.Message))

		default:

			return nil

		}

	case *pb.ValidateResponse:

		rr := r

		switch rr.Code {

		case int64(codes.OK):

			ctx.JSON(http.StatusOK, gin.H{
				"status":  "success",
				"message": rr.Message,
				"data": gin.H{
					"user_id": rr.UserId,
				},
			})

		case int64(codes.Internal):

			ctx.JSON(http.StatusInternalServerError, BaseErrorResponse(rr.Message))

		case int64(codes.InvalidArgument):

			ctx.JSON(http.StatusBadRequest, BaseErrorResponse(rr.Message))

		case int64(codes.NotFound):

			ctx.JSON(http.StatusNotFound, BaseErrorResponse(rr.Message))

		case int64(codes.AlreadyExists):

			ctx.JSON(http.StatusNotFound, BaseErrorResponse(rr.Message))

		default:

			return nil

		}

	case *pb.RenewTokenResponse:

		rr := r

		switch rr.Code {

		case int64(codes.OK):

			ctx.JSON(http.StatusOK, gin.H{
				"status":  "success",
				"message": rr.Message,
				"data": gin.H{
					"access_token":            rr.AccessToken,
					"access_token_expires_at": rr.AccessTokenExpiresAt,
				},
			})

		case int64(codes.Internal):

			ctx.JSON(http.StatusInternalServerError, BaseErrorResponse(rr.Message))

		case int64(codes.InvalidArgument):

			ctx.JSON(http.StatusBadRequest, BaseErrorResponse(rr.Message))

		case int64(codes.NotFound):

			ctx.JSON(http.StatusNotFound, BaseErrorResponse(rr.Message))

		case int64(codes.AlreadyExists):

			ctx.JSON(http.StatusNotFound, BaseErrorResponse(rr.Message))

		default:

			return nil

		}

	default:

		return nil

	}

	return nil
}

func BaseSuccessResponse(successMessage string) gin.H {
	return gin.H{
		"status":  "success",
		"message": successMessage,
	}
}

func BaseSuccessResponseWithData(successMessage string, data interface{}) gin.H {
	return gin.H{
		"status":  "success",
		"message": successMessage,
		"data":    data,
	}
}

func BaseErrorResponse(errMessage string) gin.H {
	return gin.H{
		"status":  "failed",
		"message": errMessage,
	}
}
