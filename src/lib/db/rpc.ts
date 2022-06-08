import type { Prisma, PrismaClient } from '@prisma/client';
import type { RequestEvent, RequestHandler } from '@sveltejs/kit';

export type HandlerFunction<InputType, OutputType> = ({
	input,
	prisma,
	requestEvent
}: {
	input: InputType;
	prisma: PrismaClient<
		Prisma.PrismaClientOptions,
		never,
		Prisma.RejectOnNotFound | Prisma.RejectPerOperation | undefined
	>;
	requestEvent: RequestEvent<Record<string, string>>;
	// }) => Promise<RequestHandlerOutput<ResponseBody>>;
}) => Promise<OutputType>;

// decided against this approach because svelte handles await/then/catch fine by itself
// export type RPC<InputType, OutputType> = (input: InputType) => Promise<RPCResponse<OutputType>>;
// export type RPCResponse<OutputType> = {
// 	data?: OutputType;
// 	error?: string;
// };
// .then(async (res) => ({
// 	data: await res.json()
// }))
// .catch((err) => ({
// 	error: err.message
// }));

export type RPC<InputType, OutputType> = (input: InputType) => Promise<OutputType>;

type PostRequestHandler = RequestHandler;

export const createRPC = <InputType = null, OutputType = void>(
	uri: string,
	handler: HandlerFunction<InputType, OutputType>
): [RPC<InputType, OutputType>, PostRequestHandler] => {
	const post: PostRequestHandler = async (requestEvent) => {
		const { prisma } = await import('$lib/db/prisma-client');
		const input = await requestEvent.request.json();
		const output = await handler({ input, prisma, requestEvent });
		return output
			? {
					body: JSON.stringify(output)
			  }
			: {};
	};

	const rpc: RPC<InputType, OutputType> = async (input: InputType) => {
		return fetch(uri, {
			method: 'post',
			headers: {
				'Content-Type': 'application/json',
				Accept: 'application/json'
			},
			body: JSON.stringify(input || '')
		})
			.then((res) => res.json())
			.catch((err) => {
				console.log('error!!!!!');
				console.log(err);
				return err.message;
			});
	};

	return [rpc, post];
};
