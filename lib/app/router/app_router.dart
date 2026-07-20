import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:go_router/go_router.dart';
import 'package:template/features/auth/presentation/pages/login_page.dart';
import 'package:template/features/auth/presentation/pages/onboarding_page.dart';
import 'package:template/features/auth/presentation/pages/register_page.dart';
import 'package:template/features/auth/presentation/pages/splash_page.dart';
import 'package:template/features/found_item/presentation/pages/declare_found_page.dart';
import 'package:template/features/found_item/presentation/pages/found_list_page.dart';
import 'package:template/features/home/presentation/pages/home_page.dart';
import 'package:template/features/lost_item/presentation/pages/declare_lost_page.dart';
import 'package:template/features/chat/presentation/pages/chat_page.dart';
import 'package:template/features/match/presentation/pages/match_confirmed_page.dart';
import 'package:template/features/match/presentation/pages/match_potential_page.dart';
import 'package:template/features/notifications/presentation/pages/notifications_page.dart';
import 'package:template/features/profile/presentation/pages/dashboard_page.dart';
import 'package:template/features/profile/presentation/pages/profile_page.dart';
import 'package:template/features/verification/presentation/pages/verification_page.dart';
import 'package:template/shared/presentation/widgets/navigation/main_shell.dart';

class AppRouter extends Equatable {
  static const splash = 'splash';
  static const onboarding = 'onboarding';
  static const login = 'login';
  static const register = 'register';
  static const home = 'home';
  static const declareFound = 'declare-found';
  static const declareLost = 'declare-lost';
  static const matchPotential = 'match-potential';
  static const matchConfirmed = 'match-confirmed';
  static const verification = 'verification';
  static const foundList = 'found-list';
  static const foundMatch = 'found-match';
  static const notifications = 'notifications';
  static const profile = 'profile';
  static const dashboard = 'dashboard';
  static const chat = 'chat';

  @override
  List<Object?> get props => [];
}

GoRouter router([String? initialLocation]) => GoRouter(
      debugLogDiagnostics: kDebugMode || kProfileMode,
      initialLocation: initialLocation ?? '/',
      routes: [
        // ── Auth (pas de bottom nav) ──────────────────────────────
        GoRoute(
          path: '/',
          name: AppRouter.splash,
          builder: (_, __) => const SplashPage(),
        ),
        GoRoute(
          path: '/onboarding',
          name: AppRouter.onboarding,
          builder: (_, __) => const OnboardingPage(),
        ),
        GoRoute(
          path: '/login',
          name: AppRouter.login,
          builder: (_, __) => const LoginPage(),
        ),
        GoRoute(
          path: '/register',
          name: AppRouter.register,
          builder: (_, __) => const RegisterPage(),
        ),

        // ── Shell (avec bottom nav) ───────────────────────────────
        StatefulShellRoute.indexedStack(
          builder: (_, __, navigationShell) =>
              MainShell(navigationShell: navigationShell),
          branches: [
            // ── Branch 0 : Accueil ──
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: '/home',
                  name: AppRouter.home,
                  builder: (_, __) => const HomePage(),
                  routes: [
                    GoRoute(
                      path: 'declare-found',
                      name: AppRouter.declareFound,
                      builder: (_, __) => const DeclareFoundPage(),
                    ),
                    GoRoute(
                      path: 'declare-lost',
                      name: AppRouter.declareLost,
                      builder: (_, __) => const DeclareLostPage(),
                    ),
                    GoRoute(
                      path: 'match/confirmed',
                      name: AppRouter.matchConfirmed,
                      builder: (_, __) => const MatchConfirmedPage(),
                    ),
                    GoRoute(
                      path: 'chat/:id',
                      name: AppRouter.chat,
                      builder: (_, state) => ChatPage(
                        conversationId: state.pathParameters['id'],
                      ),
                    ),
                    GoRoute(
                      path: 'match/:id',
                      name: AppRouter.matchPotential,
                      builder: (_, state) => MatchPotentialPage(
                        matchId: state.pathParameters['id'],
                      ),
                      routes: [
                        GoRoute(
                          path: 'verification',
                          name: AppRouter.verification,
                          builder: (_, __) => const VerificationPage(),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),

            // ── Branch 1 : Recherche / Objets trouvés ──
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: '/search',
                  name: AppRouter.foundList,
                  builder: (_, __) => const FoundListPage(),
                  routes: [
                    GoRoute(
                      path: 'match/:id',
                      name: AppRouter.foundMatch,
                      builder: (_, state) => MatchPotentialPage(
                        matchId: state.pathParameters['id'],
                      ),
                      routes: [
                        GoRoute(
                          path: 'verification',
                          builder: (_, __) => const VerificationPage(),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),

            // ── Branch 2 : Notifications ──
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: '/notifications',
                  name: AppRouter.notifications,
                  builder: (_, __) => const NotificationsPage(),
                ),
              ],
            ),

            // ── Branch 3 : Profil ──
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: '/profile',
                  name: AppRouter.profile,
                  builder: (_, __) => const ProfilePage(),
                  routes: [
                    GoRoute(
                      path: 'dashboard',
                      name: AppRouter.dashboard,
                      builder: (_, __) => const DashboardPage(),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ],
    );
