package gapi

import (
	"context"
	"fmt"

	"github.com/Ayobami-00/Eureka/eureka-api-auth-service-go/domain"
	"github.com/Ayobami-00/Eureka/eureka-api-auth-service-go/repository"
	"github.com/Ayobami-00/Eureka/eureka-api-auth-service-go/usecase"
	"github.com/Ayobami-00/Eureka/eureka-api-auth-service-go/utils/api_response"
	"github.com/Ayobami-00/Eureka/eureka-api-auth-service-go/utils/crypto"

	"github.com/Ayobami-00/Eureka/eureka-api-auth-service-go/pb"
	"github.com/Ayobami-00/Eureka/eureka-api-auth-service-go/utils/validator"
)

func (s *Server) Login(ctx context.Context, req *pb.LoginRequest) (*pb.LoginResponse, error) {

	err := validator.ValidateLoginRequest(req)
	if err != nil {
		return api_response.ErrorBadRequest(&pb.LoginResponse{}, err.Error()).(*pb.LoginResponse), nil
	}

	ur := repository.NewUserRepository(s.Db, s.Timeout, s.Db.UsersTableName)
	lu := usecase.NewLoginUsecase(ur)

	db_user, err := lu.GetUserByEmail(ctx, req.GetEmail())
	if err != nil {
		return api_response.ErrorNotFound(&pb.LoginResponse{}, "User doesn't exists with the given email").(*pb.LoginResponse), nil
	}

	err = crypto.VerifyPassword(req.GetPassword(), db_user.Password)
	if err != nil {
		return api_response.ErrorInternal(&pb.LoginResponse{}, "Incorrect Password").(*pb.LoginResponse), nil
	}

	accessToken, accessPayload, err := s.TokenMaker.CreateToken(
		db_user.ID,
		s.Env.AccessTokenDuration,
	)

	if err != nil {
		return api_response.ErrorInternal(&pb.LoginResponse{}, fmt.Sprintf("Failed to generate access token: %s", err)).(*pb.LoginResponse), nil
	}

	refreshToken, refreshPayload, err := s.TokenMaker.CreateToken(
		db_user.ID,
		s.Env.AccessTokenDuration,
	)

	if err != nil {
		return api_response.ErrorInternal(&pb.LoginResponse{}, fmt.Sprintf("Failed to generate refresh token: %s", err)).(*pb.LoginResponse), nil
	}

	sr := repository.NewSessionRepository(s.Db, s.Timeout, s.Db.SessionsTableName)

	err = sr.Create(ctx, &domain.Session{
		ID:           refreshPayload.ID.String(),
		Name:         db_user.ID,
		RefreshToken: refreshToken,
		UserAgent:    req.GetUserAgent(),
		ClientIp:     req.GetClientIp(),
		IsBlocked:    false,
		ExpiresAt:    refreshPayload.ExpiredAt.Unix(),
	})
	if err != nil {
		return api_response.ErrorInternal(&pb.LoginResponse{}, err.Error()).(*pb.LoginResponse), nil
	}

	sessionId := refreshPayload.ID.String()

	return api_response.Success(&pb.LoginResponse{}, "User successfully logged in", map[string]interface{}{
		"session_id":               sessionId,
		"access_token":             accessToken,
		"access_token_expires_at":  accessPayload.ExpiredAt.Unix(),
		"refresh_token":            refreshToken,
		"refresh_token_expires_at": refreshPayload.ExpiredAt.Unix(),
		"user_id":                  db_user.ID,
	}).(*pb.LoginResponse), nil

}
